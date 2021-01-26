const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.

    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },

    cldev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },

    ganache: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },

    kovan: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, process.env.KOVAN_RPC_URL);
      },
      network_id: "*",
      // ~~Necessary due to https://github.com/trufflesuite/truffle/issues/1971~~
      // Necessary due to https://github.com/trufflesuite/truffle/issues/3008
      skipDryRun: true,

      // LINK kovan
      linkAddress: "0xa36085F69e2889c224210F603D836748e7dC0088",
    },

    live: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC_LIVE, process.env.RPC_URL);
      },
      network_id: "*",
      // ~~Necessary due to https://github.com/trufflesuite/truffle/issues/1971~~
      // Necessary due to https://github.com/trufflesuite/truffle/issues/3008
      skipDryRun: true,
      // LINK live
      linkAddress: "0x514910771af9ca656af840dff83e8264ecf986ca",
    },
  },

  compilers: {
    solc: {
      version: "0.6.6",
    },
  },
};
