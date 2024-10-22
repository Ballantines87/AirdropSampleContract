// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    BagelToken token;
    MerkleAirdrop merkleAirdrop;
    bytes32 private constant s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() private returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        token = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(s_merkleRoot, token);
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(merkleAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (merkleAirdrop, token);
    }

    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
