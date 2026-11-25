# Experimental NVIDIA / small-memory revision

Base: avatarmanz/VIctory-7900XTX, 0a43566532c57b34a5397d6fdc91e419de32e8e9. Main remains unchanged.

Changes: cap empty 64 MiB texture pool blocks on adapters with a local budget of at most 6 GiB, retaining the existing two-block safety floor. Scale thin command-list worker defaults to CPU capacity. Unit tests cover the sizing policies. No changes to title files, licensing or security checks.

The upstream fork already implements upload-completion descriptor publication, memory residency synchronization, texture read-back, fullscreen pipeline prioritization, corrected cube gradients and dynamic ambient light. These are retained, not reimplemented. The low-memory launcher uses conservative settings; -Fast enables the parallel list and upload-ahead paths; -Air and -Indirect are independent visual experiments. The reported display mode is not a guaranteed internal resolution.

Build with cargo build --locked --profile diag -p victory --features diagnostics. For local testing use scripts/play-nvidia.ps1 with an authorized title. T2's package write guard has been adapted to this fork's path-taking imports; it is not an OS sandbox, so use a separate copy or OS-level read-only access when absolute isolation is required. The launcher uses distinct cache, saves and logs and restores environment variables. It does not change the old installations.

Not compiled or GPU-tested in this environment. These changes do not impose a hard cap on overall GPU or RAM use. T2-specific texture previews and the memory valve are not yet ported. The adapted package write guard has not been runtime-tested. No claim of performance gains or crash fixes before testing.

## Revision 2: T2-inspired memory safeguards

On local GPU budgets up to 6 GiB, indexed texture admission now uses a pressure-adjusted share (default 34%, or explicit ceiling). The NVIDIA launcher selects 768 MiB. Severe combined pressure pauses new optional copies, not the whole renderer. Normal texture upload passes are capped at 64 MiB/200 ms and reduced under pressure; early special passes retain their existing limits. Idle scratch retention reduces to 128 MiB when free physical RAM falls below 4 GiB, including reclaim of previously retained idle chunks. Live resources and in-flight lists retain their ownership and synchronization. Added policy unit tests; not executed here. These are partial T2 adaptations, not a port of its preview renderer or full memory-recovery system. Overall memory usage can still exceed the GPU budget.
