'use strict';

// Error yang membawa status HTTP dan detail, supaya controller bisa
// membalas dengan benar (404, 409, 422, 502, ...).
class AiError extends Error {
  constructor(status, message, details, publicMessage) {
    super(message);
    this.name = 'AiError';
    this.status = status;
    this.details = details;
    // Pesan aman untuk 5xx (errorHandler tidak membocorkan detail internal).
    this.publicMessage = publicMessage;
  }
}

module.exports = AiError;
