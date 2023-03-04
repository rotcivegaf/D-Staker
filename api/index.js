const dotenv = require('dotenv');
dotenv.config();

const axios = require('axios');
const { SSVKeys } = require('ssv-keys');
const { Contract, ethers, Wallet, utils } = require('ethers');

const { STAKING_POOL_ADDRESS, PRIVATE_KEY, RPC_URL, KEYSTORE_PASSWORD, WETH_ADDRESS } = process.env;

const STAKING_POOL_ABI = [
	'function registerValidator(bytes,uint32[],bytes[],bytes[],uint256) external',
	'function depositValidatorStaking(bytes,bytes,bytes,bytes32) external'
];

const ERC20_ABI = [`function balanceOf(address) view returns(uint256)`];

function getProvider() {
	const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
	return provider;
}

function getContract() {
	const provider = getProvider();
	const signer = new Wallet(PRIVATE_KEY, provider);
	const contractInstance = new Contract(STAKING_POOL_ADDRESS, STAKING_POOL_ABI, signer);
	return contractInstance;
}

function getWETHContract() {
	const provider = getProvider();
	const signer = new Wallet(PRIVATE_KEY, provider);
	const contractInstance = new Contract(WETH_ADDRESS, ERC20_ABI, signer);
	return contractInstance;
}

// async function registerValidatorAndDeposit(registerValidatorAndDepositData) {
// 	console.log('registerValidatorAndDeposit');
// 	const contract = getContract();
// 	const tx = await contract.registerValidatorAndDeposit(
// 		registerValidatorAndDepositData.pubKey,
// 		registerValidatorAndDepositData.operatorIds,
// 		registerValidatorAndDepositData.sharePublicKeys,
// 		registerValidatorAndDepositData.shareEncrypted,
// 		utils.parseEther(10),
// 		registerValidatorAndDepositData.withdrawal_credentials,
// 		registerValidatorAndDepositData.signature,
// 		registerValidatorAndDepositData.deposit_data_root
// 	);
// 	const receipt = await tx.wait();
// 	return receipt;
// }

async function registerValidator(registerValidatorData) {
	const contract = getContract();

	const tx = await contract.registerValidator(
		registerValidatorData.pubKey,
		registerValidatorData.operatorIds,
		registerValidatorData.sharesPublicKeys,
		registerValidatorData.sharesEncrypted.map((shares) => utils.toUtf8Bytes(shares)),
		utils.parseEther('10')
	);

	const receipt = await tx.wait();
	return receipt;
}

async function depositValidatorStaking(depositValidatorStakingData) {
	const contract = getContract();
	const tx = await contract.depositValidatorStaking(
		depositValidatorStakingData.pubKey,
		`0x${depositValidatorStakingData.withdrawal_credentials}`,
		`0x${depositValidatorStakingData.signature}`,
		`0x${depositValidatorStakingData.deposit_data_root}`,
		{ gasLimit: 1000000 }
	);
	const receipt = await tx.wait();
	return receipt;
}

const keystores = [
	require('../config/keystores/keystore1.json'),
	require('../config/keystores/keystore2.json'),
	require('../config/keystores/keystore3.json'),
	require('../config/keystores/keystore4.json'),
	require('../config/keystores/keystore5.json')
];

const deposits = [
	require('../config/deposits/deposit1.json'),
	require('../config/deposits/deposit2.json'),
	require('../config/deposits/deposit3.json'),
	require('../config/deposits/deposit4.json'),
	require('../config/deposits/deposit5.json')
];

async function getOperators() {
	console.log('getting operators');
	const { data } = await axios.get(`https://api.ssv.network/api/v2/prater/operators`);

	const filteredOperators = data.operators.filter(
		({ is_active, status, is_valid, is_deleted }) =>
			!!is_active && !is_deleted && is_valid && status === 'Active'
	); // this is paginated

	const choosenOperators = [];
	for (let i = 0; i < 4; i++) {
		const index = Math.floor(Math.random() * filteredOperators.length);
		const operator = filteredOperators[index];
		filteredOperators[index] = filteredOperators[filteredOperators.length - 1];
		filteredOperators.pop();
		choosenOperators.push({
			id: parseInt(operator.id, 10),
			publicKey: operator.public_key
		});
	}
	return choosenOperators;
}

function generateValidatorData() {
	const index = Math.floor(Math.random() * keystores.length);

	const keystore = keystores[index];
	keystores[index] = keystores[keystores.length];
	keystores.pop();

	const deposit = deposits[index];
	deposits[index] = deposits[deposits.length];
	deposits.pop();

	return { keystore, deposit };
}

async function main() {
	const contract = getContract();
	const weth = getWETHContract();
	let balance = await weth.balanceOf(contract.address);

	console.log('current balance', utils.formatEther(balance));

	const etherAmountPerNode = utils.parseEther('32');

	// just create new validators if needed ether amount is reached
	if (balance.lt(etherAmountPerNode)) {
		console.error('insufficient balance');
		return;
	}

	while (balance.gt(etherAmountPerNode)) {
		const { keystore, deposit } = generateValidatorData();
		const ssvKeys = new SSVKeys(SSVKeys.VERSION.V3);
		const keystorePassword = KEYSTORE_PASSWORD;

		const privateKey = await ssvKeys.getPrivateKeyFromKeystoreData(keystore, keystorePassword);

		const operators = await getOperators();

		const operatorIds = operators.map(({ id }) => id);

		const encryptedShares = await ssvKeys.buildShares(
			privateKey,
			operatorIds,
			operators.map(({ publicKey }) => publicKey)
		);

		const payload = await ssvKeys.buildPayload({
			publicKey: ssvKeys.publicKey,
			operatorIds,
			encryptedShares
		});

		const keyShares = await ssvKeys.keyShares.fromJson({
			version: 'v3',
			data: {
				operators,
				publicKey: ssvKeys.publicKey,
				encryptedShares
			},
			payload
		});

		const registerValidatorData = {
			pubKey: keyShares.data.publicKey,
			operatorIds: keyShares.data.operators.map(({ id }) => id),
			sharesPublicKeys: keyShares.data.shares.publicKeys,
			sharesEncrypted: keyShares.data.shares.encryptedKeys
		};

		console.log('registering validator');
		await registerValidator(registerValidatorData);

		const depositValidatorStakingData = {
			pubKey: keyShares.data.publicKey,
			withdrawal_credentials: deposit.withdrawal_credentials,
			signature: deposit.signature,
			deposit_data_root: deposit.deposit_data_root
		};

		console.log('depositing validator staking');
		await depositValidatorStaking(depositValidatorStakingData);
		console.log('validator added');

		console.log('done!');

		// continue adding validators
		balance = await weth.balanceOf(contract.address);
		console.log('current balance', utils.formatEther(balance));
	}
}

main().catch(console.error);
