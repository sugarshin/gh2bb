# gh2bb

## env

```
$ cp .env{.example,}
$ vim .env
```

```
## grab from https://github.com/settings/tokens
# generate token with `repo:all` permission
GITHUB_ACCESS_TOKEN=
GITHUB_TARGET_USERNAME=
# orgs or users
GITHUB_TARGET_TYPE=
BITBUCKET_USERNAME=
## grap from https://bitbucket.org/account/settings/app-passwords/
# create app password with `repository:admin`
BITBUCKET_APP_PASSWORD=
```

## Example

```
$ /bin/bash run.sh private
```
