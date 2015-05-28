# Debian base image generator
日本向けにカスタマイズした Debian の Base image (`rootfs.tar.xz`) を生成します。


## Japanize
生成されるイメージには以下の設定がされています。

- Generated Locale: `ja_JP.UTF-8`
- Default Locale: `None`
- Timezone: `Asia/Tokyo (JST)`
- APT mirror: `ftp.jp.debian.org`


## Base docker image
- `debian:latest`


## Working directory
- `/docker`


## Mountable directory
- `/docker/image`


## Usage
```sh
docker run --rm --privileged -v <docker-image-dir>:/docker/image hatyuki/debian-builder build <release>
```

`<docker-image-dir>` にホストのディレクトリを指定してください。
指定したディレクトリに Japanize された `rootfs.tar.xz` と `Dockerfile` が生成されます。

### Import base image
生成された Base image は以下のコマンドで build できます。

```sh
docker build <docker-image-dir>
```

### Release
`<release>` には以下の値を指定することができます。

- wheezy
- jessie
- stretch
- sid
- stable (Default)
- testing
- ... (Debian の release に従う)
