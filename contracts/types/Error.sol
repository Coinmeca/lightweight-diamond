// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library ERROR {
    error CODE(TYPE __);

    enum TYPE {
        LOCKED,                     // 0
        REENTRANCY,                 // 1
        NO_PERMISSION,              // 2
        IMPOSSIBLE_MINT,            // 3
        WRONG_REQUEST,              // 4
        BANNED_ACCOUNT,             // 5
        MISMATCH_OWNER,             // 6
        MISMATCH_MARKET,            // 7
        EXIST_TOKEN,                // 8
        EXIST_MARKET,               // 9
        UNSUPPORTED_CURRENCY,       // 10
        NOT_ENOUGH_MECA,            // 11
        NOT_ENOUGH_LIQUIDITY,       // 12
        NOT_ENOUGH_REWARDS,         // 13
        NOT_FILLED_YET,             // 14
        NOT_STAKE_YET,              // 15
        INSUFFICIENT_AMOUNT,        // 16
        INSUFFICIENT_BALANCE,       // 17
        INSUFFICIENT_REWARD,        // 18
        INSUFFICIENT_LIQUIDITY,     // 19
        CANNOT_LIST_NATIVE_TOKEN,   // 20
        ZERO_PRICE,                 // 21
        LOW_PRICE,                  // 22
        LOW_AMOUNT,                 // 23
        LOW_QUANTITY,               // 24
        LOW_REWARD,                 // 25
        NOT_FILLED,                 // 26
        ALREADY_FILLED,             // 27
        ALREADY_CLAIMED,            // 28
        NO_LEVERAGE,                // 29
        NO_REWARD                   // 30
    }
}