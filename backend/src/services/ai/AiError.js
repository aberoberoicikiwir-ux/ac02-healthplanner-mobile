'use strict';

// Error yang membawa status HTTP dan detail, supaya controller bisa
// membalas dengan benar (404, 409, 422, 502, ...).
class AiError extends Error {
  constructor(status, message, details) {
    super(message);
    this.name = 'AiError';
    this.status = status;
    this.details = details;
  }
}

module.exports = AiError;
