using RustToolChain: rustc

run(`$(rustc()) main.rs`)
run(`./main`)
