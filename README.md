# Detecting drift when using git submodules

Git submodules are a convenient way to vendor source code, especially if you want to build the repositories without having to manage updating a fork and maintaining your own build-specific configurations during these syncs. One disadvantage to these submodules, however, is that the updates included can easily be opaque which can easily result in drift between your build process and that of the original repository. This becomes harder when you have an external tool like Renovate which automatically suggests updates to the submodules.

`drift-detection` can be used to resolve this disadvantage (feel free to even use _this_ as a submodule!) by providing a simple and reusable script which can fail builds if any drift is detected.

`drift-detection` relies on comparing local caches of "build sensitive" files and comparing those against the submodules at build time. Some common build sensitive files may include Containerfiles and Makefiles that are used to define the packages' build process upstream.

The process for using this tool is:

0. Include this repository as a submodule in your repository
1. Store a copy of the submodules' sensitive files ensuring that they are clearly identifiable and separated from each other.
2. Modify your build process (for example a Containerfile) to compare the cached files against those pulled in from the submodule:

```dockerfile
COPY drift-detection/detector.sh /detector.sh
# Check to see if we need to react to any uptream changes
COPY drift-cache /drift-cache
WORKDIR /tmp
COPY submodule-path/Dockerfile .
RUN /detector.sh ./Dockerfile /drift-cache/submodule-name/Dockerfile
```

3. If the files match, `detector.sh` will return cleanly and the build will continue. If the files do not match, `detector.sh` will display the mismatched content and will error out, causing your build to fail.
4. If your build fails, update the cached files and make any required changes (if any) to your build process. Commit and push the content to the PR to retest the change.

*NOTE: Some changes that cause failures will NOT require a similar change to be made in your local build process. For example, if a comment is modified in a Containerfile.*