# Experimental NVIDIA / small-memory revision

Base: avatarmanz/VIctory-7900XTX, 0a43566532c57b34a5397d6fdc91e419de32e8e9. Main remains unchanged.

Changes: cap empty 64 MiB texture pool blocks on adapters with a local budget of at most 6 GiB, retaining the existing two-block safety floor. Scale thin command-list worker defaults to CPU capacity. Unit tests cover the sizing policies. No changes to title files, licensing or security checks.

The upstream fork already implements upload-completion descriptor publication, memory residency synchronization, texture read-back, fullscreen pipeline prioritization, corrected cube gradients and dynamic ambient light. These are retained, not reimplemented. The low-memory launcher uses conservative settings; -Fast enables the parallel list and upload-ahead paths; -Air and -Indirect are independent visual experiments. The reported display mode is not a guaranteed internal resolution.

Build with cargo build --locked --profile diag -p victory --features diagnostics. For local testing use scripts/play-nvidia.ps1 with an isolated, authorized title copy, not the original package. Upstream does not yet contain T2's package write guard. The launcher uses distinct cache, saves and logs and restores environment variables. It does not change the old installations.

Not compiled or GPU-tested in this environment. These changes do not impose a hard cap on overall GPU or RAM use. T2-specific texture previews, the memory valve and write guard are not yet ported. No claim of performance gains or crash fixes before testing.
