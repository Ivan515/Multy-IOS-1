//
//  DMTokenExtension.swift
//  Multy
//
//  Created by Alex Pro on 11/6/18.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import Foundation
import Web3

extension DataManager {
    func updateTokensInfo(_ tokensarray: [TokenRLM]) {
        if tokensarray.count == 0 {
            return
        }
        
        let tokenCount = tokensarray.count
        var newTokenInfo = [TokenRLM]()
        
        let blockchainType = tokensarray.first!.blockchainType
        let rpcURL = (blockchainType.net_type == ETHEREUM_CHAIN_ID_MAINNET.rawValue ? "https://mainnet.infura.io/v3/78ae782ed28e48c0b3f74ca69c4f7ca8" : (UInt32(blockchainType.net_type) == ETHEREUM_CHAIN_ID_RINKEBY.rawValue ? "https://rinkeby.infura.io/v3/78ae782ed28e48c0b3f74ca69c4f7ca8" : "" ))
        let web3 = Web3(rpcURL: rpcURL)
        
        tokensarray.forEach { [unowned self] in
            let newToken = TokenRLM()
            newToken.contractAddress = $0.contractAddress
            newToken.currencyID     = $0.currencyID
            newToken.netType        = $0.netType
            newToken.ticker         = $0.ticker
            newToken.name           = $0.name
            newToken.decimals       = $0.decimals
            
            let contractAddress = try! EthereumAddress(hex: $0.contractAddress.lowercased(), eip55: false)
            let contract = web3.eth.Contract(type: GenericERC20Contract.self, address: contractAddress)
            let name = contract.name()
            let dec = contract.decimals()
            let symbol = contract.symbol()
            
//            let call = EthereumCall(from: contractAddress,
//                                    to: contractAddress,
//                                    gas: EthereumQuantity(integerLiteral: 21_000),
//                                    gasPrice: EthereumQuantity(integerLiteral: 1_000_000_000),
//                                    value: EthereumQuantity(integerLiteral: 1_000_000_000_000_000),
//                                    data: nil)
            
//            contract.estimateGas(call) { (quantity, error) in
//                print("\(newToken.name): \(quantity?.quantity.description)")
//            }
            
            name.call { [unowned self] (dict, error) in
                if dict != nil, dict!.keys.count > 0 {
                    newToken.name = dict!.values.first! as! String
                }
                
                dec.call { [unowned self] (dict, error) in
                    if dict != nil, dict!.keys.count > 0 {
                        newToken.decimals = dict!.values.first! as! NSNumber
                    } else {
                        newToken.decimals = 0
                    }
                    
                    symbol.call { [unowned self] (dict, error) in
                        if dict != nil, dict!.keys.count > 0 {
                            newToken.ticker = dict!.values.first! as! String
                        }
                        
                        //lock access to newTokenInfo
//                        objc_sync_enter(newTokenInfo)
                        
                        newTokenInfo.append(newToken)
                        print("newTokenInfo: \(newTokenInfo.count)")
                        
                        if newTokenInfo.count == tokenCount {
                            DispatchQueue.main.async { [unowned self] in
                                self.realmManager.updateErc20Tokens(tokens: newTokenInfo)
                            }
                        }
//                        objc_sync_exit(newTokenInfo)
                    }
                }
            }
        }
    }
}
