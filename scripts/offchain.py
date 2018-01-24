import json

import sys
import web3

from web3 import Web3, HTTPProvider, RPCProvider
from web3.contract import ConciseContract



contract_address = '0x345ca3e014aaf5dca488057592ee47305d9b3e10'
contract_owner = '0x627306090abab3a6e1400e9345bc60c78a8bef57'
beneficiar_address=str(sys.argv[1])
beneficiar_amount= int(sys.argv[2])

w3 = Web3(RPCProvider(port=7545))


print("Offchain payment %s to %s" %(beneficiar_amount,beneficiar_address))
interface = json.load(open('../build/contracts/MavroTokenSale.json',"r"))['abi']


contract_instance = w3.eth.contract(interface, contract_address,ContractFactoryClass=ConciseContract)


txHash = contract_instance.offchainPurchase(beneficiar_address,beneficiar_amount, transact={'from': contract_owner})
print(txHash)
