# Minecraft OpenStack VM

This root module provisions the Minecraft VM and a persistent Cinder data volume.
The NixOS configuration mounts the volume at `/srv/minecraft`, which is also
`services.minecraft-servers.dataDir`.

## Data Volume

- OpenTofu resource: `openstack_blockstorage_volume_v3.minecraft_data`
- OpenTofu attachment: `openstack_compute_volume_attach_v2.minecraft_data`
- Filesystem label expected by NixOS: `minecraft-data`
- Mount point: `/srv/minecraft`
- Default size: `50` GiB (`data_volume_size_gb`)

The volume has `prevent_destroy = true` to avoid accidental data loss.

## Migration From Root Volume

Run these commands from the repo root unless noted.

1. Create and attach the data volume.

   ```bash
   tofu -chdir=infra/openstack/minecraft plan
   tofu -chdir=infra/openstack/minecraft apply
   ```

2. SSH to the VM and stop both Minecraft servers.

   ```bash
   ssh akazdayo@$(tofu -chdir=infra/openstack/minecraft output -raw ssh_host)
   sudo systemctl stop minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
   sudo systemctl is-active minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
   ```

   `systemctl is-active` should print `inactive` for both services.

3. Identify the newly attached blank disk.

   ```bash
   lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS
   ```

   Pick the disk with no `FSTYPE` and no mount point. On many OpenStack VMs it
   is `/dev/vdb`, but verify before formatting.

4. Format only the new blank disk.

   Replace `/dev/vdb` with the disk confirmed in the previous step.

   ```bash
   sudo mkfs.ext4 -L minecraft-data /dev/vdb
   ```

5. Temporarily mount the new volume and copy the current data.

   ```bash
   sudo mkdir -p /mnt/minecraft-data
   sudo mount /dev/disk/by-label/minecraft-data /mnt/minecraft-data
   sudo rsync -aHAX --numeric-ids /srv/minecraft/ /mnt/minecraft-data/
   sudo rsync -aHAXn --delete --numeric-ids /srv/minecraft/ /mnt/minecraft-data/
   ```

   The dry-run `rsync` should produce no file changes.

6. Keep the old root-volume data as an immediate rollback copy, then free the
   mount point.

   ```bash
   sudo mv /srv/minecraft /srv/minecraft.root-volume.$(date +%Y%m%d%H%M%S)
   sudo mkdir -p /srv/minecraft
   sudo umount /mnt/minecraft-data
   ```

7. Deploy the NixOS config so `/srv/minecraft` is mounted declaratively.

   ```bash
   nix run .#deploy-openstack -- minecraft
   ```

8. Verify the mount and services.

   ```bash
   findmnt /srv/minecraft
   ls -la /srv/minecraft
   sudo systemctl status minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
   sudo journalctl -u minecraft-server-fabric-smp.service -u minecraft-server-fabric-creative.service -n 100 --no-pager
   ```

   If the services are not running after deploy, start them manually:

   ```bash
   sudo systemctl start minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
   ```

## After Migration

- Confirm `findmnt /srv/minecraft` shows `/dev/disk/by-label/minecraft-data`.
- Confirm both servers start and players can join through Velocity.
- Keep `/srv/minecraft.root-volume.<timestamp>` until the server has run long
  enough to trust the migration.
- After that, remove the old root-volume copy to reclaim space:

  ```bash
  sudo rm -rf /srv/minecraft.root-volume.<timestamp>
  ```

## Rollback

Use this only before deleting the root-volume backup.

```bash
sudo systemctl stop minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
sudo umount /srv/minecraft
sudo rmdir /srv/minecraft
sudo mv /srv/minecraft.root-volume.<timestamp> /srv/minecraft
sudo systemctl start minecraft-server-fabric-smp.service minecraft-server-fabric-creative.service
```

Then revert the NixOS mount/module change and deploy again.
