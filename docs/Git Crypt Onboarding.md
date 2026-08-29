# Git Crypt

Using git crypt is easy if you let it be, so put down your Claude (or whatever agent you are using idc) and follow along.

> [!IMPORTANT]
> There are two people involved in this process, you will NOT be able to add your key on your own. If you do decide to add your own key `git-crypt unlock` will not work! This guide will be split into two parts.


## The New Contributor

First, make sure you have `gnupg` installed, you will need it to generate pgp keys.

1. First make a new gpg key.
```
gpg --gen-key
```
It will prompt for your name and email, make sure these are correct!

You should be familar with the id of your key. You can see it by doing `gpg --list-keys`. Your key ID will be the second line (under pub ... [expires...).

2. Export your key
```
gpg --export --armor $KEY_ID
```

You should see something like:
```
-----BEGIN PGP PUBLIC KEY BLOCK-----

blahblahblahthisisrandomnumbersandletters
sagoiwaeghesouaghoesiahgoeishgoiesughe
segohseguohsehgoueshgseuoahgasueohgugse
etc...
-----END PGP PUBLIC KEY BLOCK-----
```

3. Copy the above output and send it to a current maintainer of the server.

## The Maintainer

Your job is easy, import and add the gpg user

1. Import the gpg key 

First copy the key the new contributor has and put it in a gpg file. Then import that file with:

```
gpg --import /path/to/file.gpg
```

2. Add gpg user

You need the contributors email for this step, the same one the key was generated with. After you have this email, do:
```
gpg add-gpg-user --trusted $NEW_PERSONS_EMAIL
```

After commiting these changes to the repo, the new contributor should be able to decrypt/encrypt freely by running the respective commands.
```
git-crypt unlock

and

git-crypt lock
```


