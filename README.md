# Documentation of `fixYarnDeps` issue discovered through this flake

dokielie has two entries in its `yarn.lock` that resolve to the same `github.com` url:

```
"green-turtle@git://github.com/bergos/green-turtle.git#master", "green-turtle@https://github.com/csarven/green-turtle#master":
  version "1.4.0"
  resolved "https://github.com/csarven/green-turtle#081ae1c39591e7502ac5f9c121253e18122d2a71"
```

When using `fetchYarnDeps` on this project, this causes the afformentioned Github dependency (`green-turtle`) to fetched twice,
which means that internally in `fetchYarnDeps`, `nix-prefetch-git` is called twice for the same exact repo and revision.

This leads to the following error (and similar errors, I'm not sure when which of the errors occurs):

```log
[...]
downloading https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.2.11.tgz
downloading https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.2.11.tgz
downloading https://github.com/csarven/green-turtle
downloading https://github.com/csarven/green-turtle
downloading https://registry.yarnpkg.com/has-bigints/-/has-bigints-1.0.2.tgz
downloading https://registry.yarnpkg.com/has-bigints/-/has-bigints-1.0.2.tgz
downloading https://registry.yarnpkg.com/has-flag/-/has-flag-3.0.0.tgz
Error: Command failed: nix-prefetch-git --out csarven_green_turtle.tmp --url https://github.com/csarven/green-turtle --rev 081ae1c39591e7502ac5f9c121253e18122d2a71 --builder
fatal: cannot copy '/nix/store/p45c31p2qhwjy4vf60v2d2mw9bvvpb67-git-2.45.2/share/git-core/templates/hooks/commit-msg.sample' to '/nix/store/9nyg6qj21776n21jvrcww9q0bi22bwxh-offline/csarven_green_turtle.tmp/.git/hooks/commit-msg.sample': File exists

    at genericNodeError (node:internal/errors:984:15)
    at wrappedFn (node:internal/errors:538:14)
    at ChildProcess.exithandler (node:child_process:422:12)
    at ChildProcess.emit (node:events:519:28)
    at maybeClose (node:internal/child_process:1105:16)
    at Socket.<anonymous> (node:internal/child_process:457:11)
    at Socket.emit (node:events:519:28)
    at Pipe.<anonymous> (node:net:338:12) {
  code: 128,
  killed: false,
  signal: null,
  cmd: 'nix-prefetch-git --out csarven_green_turtle.tmp --url https://github.com/csarven/green-turtle --rev 081ae1c39591e7502ac5f9c121253e18122d2a71 --builder',
  stdout: '',
  stderr: "fatal: cannot copy '/nix/store/p45c31p2qhwjy4vf60v2d2mw9bvvpb67-git-2.45.2/share/git-core/templates/hooks/commit-msg.sample' to '/nix/store/9nyg6qj21776n21jvrcww9q0bi22bwxh-offline/csarven_green_turtle.tmp/.git/hooks/commit-msg.sample': File exists\n"
}
```

It is questionable whether this is intended behaviour by `nix-pretech-git`, but for now it seems easier to simply fix `fetchYarnDeps` instead of fixing `nix-prefetch-git`.

By deduplicating dependencies according to their `resolved` key, each individual dependency is only fetched once,
which fixes the issue and allows dokilie to build correctly.

A possible implementation of this deduplication exists at https://github.com/feathecutie/nixpkgs/tree/fix-fetch-yarn-deps.
