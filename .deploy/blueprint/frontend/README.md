# frontend

## Description

A basic stack providing only a nginx webserver providing static resources of a frontend application.

## Bootstrap a Frontend Nginx Application

```bash
target=test/example/frontend
kpt pkg get git@github.com:wolf-gmbh/common-kpt-blueprints.git/frontend@main "$target" --for-deployment
```

```bash
target=test/example/frontend

folder="${target%/*}"
application="${target##*/}"
domain="MY-DOMAIN"
product="MY-PRODUCT"

mkdir -p "$folder"

#todo: any better way than to replace strings in the kpt file?
sed -i "s/<domain>/$domain/g" "$target/Kptfile"
sed -i "s/<product>/$product/g" "$target/Kptfile"
sed -i "s/<application>/$application/g" "$target/Kptfile"

kpt fn render "$target"
```
