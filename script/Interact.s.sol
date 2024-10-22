// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_1, PROOF_2];
    bytes private SIGNATURE =
        hex"ffe00065521ad673dedcfca20677ac08669efe6625324998203ec89eaba9e89e397c4fe85a8d951d47982c5399108dad40f7494a8d97b1605b0d5a66ce1d03e41c";

    error ClaimAirdropScript__InvalidSignatureLength();

    function claimAirdrop(address contractAddress) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(contractAddress).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external returns (MerkleAirdrop) {
        address mostRecentlyDeployedMerkleAirdropContract =
            DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployedMerkleAirdropContract);
    }
}
