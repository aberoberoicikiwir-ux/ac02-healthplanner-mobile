const Joi = require('joi');

const listClientsQuery = Joi.object({
  status: Joi.string().valid('active', 'inactive').default('active'),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  search: Joi.string().trim().max(100).allow('').default(''),
  sort: Joi.string()
    .valid('client_id', 'name', 'weight_current', 'weight_target', 'status')
    .default('name'),
  order: Joi.string().valid('asc', 'desc').default('asc'),
}).unknown(false);

module.exports = { listClientsQuery };
