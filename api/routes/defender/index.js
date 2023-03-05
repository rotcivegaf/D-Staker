'use strict';

const registerValidators = require('../../lib/validator');

module.exports = async function (fastify, opts) {
	fastify.get('/', async function (request, reply) {
		registerValidators();
		return 'running';
	});
};
