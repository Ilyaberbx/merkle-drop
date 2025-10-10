PHONY: deploy

deploy-anvil:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 -vvv 
	
claim-anvil:
	@forge script script/ClaimAirdop.s.sol:ClaimAirdop --rpc-url http://localhost:8545 --broadcast --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d -vvv 
	