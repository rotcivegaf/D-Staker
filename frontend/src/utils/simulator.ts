import axios from 'axios';

const { VITE_TENDERLY_ACCESS_KEY, VITE_TENDERLY_USER, VITE_TENDERLY_PROJECT, VITE_CHAIN_ID } =
	import.meta.env;

export async function simulate(data: any) {
	console.time('Simulation');

	const resp = await axios.post(
		`https://api.tenderly.co/api/v1/account/${VITE_TENDERLY_USER}/project/${VITE_TENDERLY_PROJECT}/simulate`,
		// the transaction
		{
			/* Simulation Configuration */
			save: false, // if true simulation is saved and shows up in the dashboard
			save_if_fails: false, // if true, reverting simulations show up in the dashboard
			simulation_type: 'quick', // full or quick (full is default)

			// network_id: VITE_CHAIN_ID, // network to simulate on
			network_id: '5',

			...data
			/* Standard EVM Transaction object */
			// from: '0xdc6bdc37b2714ee601734cf55a05625c9e512461',
			// to: '0x6b175474e89094c44da98b954eedeac495271d0f',
			// input:
			// 	'0x095ea7b3000000000000000000000000f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1000000000000000000000000000000000000000000000000000000000000012b',
			// gas: 8000000,
			// gas_price: 0,
			// value: 0
		},
		{
			headers: {
				'X-Access-Key': VITE_TENDERLY_ACCESS_KEY as string
			}
		}
	);
	console.timeEnd('Simulation');

	const transcation = resp.data.transaction;
	console.log(JSON.stringify(transcation, null, 2));
	return transcation.status === true;
}
