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

   create the folders before starting the containers, otherwise Docker creates them owned by root

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

4. **set up Jellyfin** (http://localhost:8096)
   - complete the setup wizard and create the admin user
   - the Movies, Shows and Animated libraries are already defined in
     `jellyfin_data/root/default`. if they don't show up, add them manually
     under Dashboard → Libraries, pointing at `/media/Movies`, `/media/Shows`
     and `/media/Animated`
   - run a library scan. posters and metadata download automatically.

## updating

```bash
docker compose pull && docker compose up -d
```
