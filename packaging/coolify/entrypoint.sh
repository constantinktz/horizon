#!/bin/sh
# Starts horizon-server in /data (the volume). The first start writes server.toml from HORIZON_*; the content
# mods built into the image are copied to /data/horizon-mods/ and turned on in /data/horizon-mods.txt.
set -eu
cd /data

# The game listens on 25565 in the container; the compose file maps the host port to it.
if [ ! -f server.toml ]; then
    HORIZON_PORT=25565 horizon-server init --yes || exit 1
fi

# Content mods from the image. The ones an older image put here are removed first; mods you put in
# /data/horizon-mods/ by hand stay (turn them on yourself in horizon-mods.txt).
mkdir -p horizon-mods
touch horizon-mods.txt
if [ -f horizon-mods/.from-image ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && rm -f "horizon-mods/$f"
    done < horizon-mods/.from-image
fi
: > horizon-mods/.from-image
for f in /opt/horizon/content/*.hmod; do
    [ -f "$f" ] || continue
    cp -f "$f" horizon-mods/
    basename "$f" >> horizon-mods/.from-image
done
while IFS= read -r id; do
    [ -n "$id" ] || continue
    sed -i "/^mod\.$id:/d" horizon-mods.txt
    echo "mod.$id:true" >> horizon-mods.txt
done < /opt/horizon/content/ids.txt

if [ -s /opt/horizon/native-mods.txt ]; then
    echo "Native mods in this build: $(tr '\n' ' ' < /opt/horizon/native-mods.txt)"
fi
if [ -s /opt/horizon/content/ids.txt ]; then
    echo "Content mods turned on: $(tr '\n' ' ' < /opt/horizon/content/ids.txt)"
fi

exec horizon-server run
