with-env {
    THOR_PLUGIN_NAME: "test-plugin"
    THOR_BUILD_PATH: "./build/"
} {
    let plugin_path = $env.THOR_BUILD_PATH + $env.THOR_PLUGIN_NAME + ".clap"
    mkdir $env.THOR_BUILD_PATH
    odin build src -build-mode:dll -out:($plugin_path)
    clap-validator -v trace validate ($plugin_path)
}
