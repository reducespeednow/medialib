# medialib

<img width="2875" height="1608" alt="image" src="https://github.com/user-attachments/assets/e5210cc4-4228-4bdd-9a19-60e3fff3a412" />

self-hosted media stack using Docker Compose:

- **Jellyfin** – streams the library at http://localhost:8096
- **qBittorrent** – downloads at http://localhost:9091; `auto_move.sh` moves finished downloads into the library

## layout

| host path        | Jellyfin  | qBittorrent    | purpose                     |
| ---------------- | --------- | -------------- | --------------------------- |
| `shared_media/`  | `/media`  | `/media_final` | finished library            |
| `downloads/`     | –         | `/downloads`   | in-progress downloads       |
| `jellyfin_data/` | `/config` | –              | Jellyfin config             |
| `qbit_data/`     | –         | `/config`      | qBittorrent config + script |

`shared_media/` and `downloads/` are not in git

## install

1. **clone and create media folders**

   ```bash
   git clone git@github.com:reducespeednow/medialib.git MediaServer && cd MediaServer
   mkdir -p downloads shared_media/{videos,shows,animated}
   chmod +x qbit_data/auto_move.sh
   ```

   create the folders before starting the containers, otherwise Docker creates them owned by root. `PUID`/`PGID` in `docker-compose.yml` must match user (`id -u` / `id -g`), otherwise qBittorrent can't write into `shared_media/`

2. **start the stack**

   ```bash
   docker compose up -d
   ```

3. **set up qBittorrent** (http://localhost:9091)
   - username is `admin`. the temporary password is printed in the logs:
     `docker logs qbittorrent`
   - Tools → Options → Web UI: set a permanent password
   - Downloads → Default save path: `/downloads`
   - Downloads → "Run external program on torrent finished":
     `bash /config/auto_move.sh "%F" "%L" "%N"`
   - give every torrent a category (`movies`, `shows` or `animated`), otherwise the script skips it. check `qbit_data/debug.log` if something doesn't move. to re-run it by hand, run it inside the container: `docker exec qbittorrent bash /config/auto_move.sh "/downloads/<name>" shows "<name>"`

4. **set up Jellyfin** (http://localhost:8096)
   - complete the setup wizard and create the admin user
   - the Movies, Shows and Animated libraries are already defined in
     `jellyfin_data/root/default`. if they don't show up, add them manually
     under Dashboard → Libraries, pointing at `/media/Movies`, `/media/Shows`
     and `/media/Animated`
   - run a library scan. posters and metadata download automatically.

## watching on a tv (raspberry pi)

a Pi 4 or Pi 5 running LibreELEC (Kodi) works as a TV client for the server. the Pi only plays media; the stack above keeps running on the host machine.

1. **flash LibreELEC**
   - on a laptop, open [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
   - choose the Pi model, then OS → Media player OS → LibreELEC, and write it to a microSD card (16GB+)

2. **connect the Pi**

3. **add the Jellyfin repository**
   - Settings → System → Add-ons: enable "Unknown sources"
   - Settings → File manager → Add source: `https://kodi.jellyfin.org`, name it `jellyfin`
   - Add-ons → Install from zip file → `jellyfin` → `repository.jellyfin.kodi.zip`

4. **install the add-on**
   - Add-ons → Install from repository → Kodi Jellyfin Add-ons → Video add-ons → **Jellyfin**
   - it syncs the library into Kodi's normal Movies/TV menus. **JellyCon** (same repo) is a lighter alternative that browses the server without syncing

5. **connect to the server**
   - open the add-on and enter the host machine's LAN address, e.g. `http://192.168.1.x:8096` (not `localhost`). find it with `ip -4 addr` on the host
   - auto-discovery may not work because Jellyfin runs in Docker, so enter the address manually
   - log in with a Jellyfin user and pick the libraries to sync

notes:

- the host's firewall must allow port `8096` from the LAN

## updating

```bash
docker compose pull && docker compose up -d
```
