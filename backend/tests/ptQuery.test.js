const test = require('node:test');
const assert = require('node:assert/strict');
const { listClientsQuery } = require('../src/schemas/ptSchema');

test('query default: active, page 1, limit 10', () => {
  const { error, value } = listClientsQuery.validate({});
  assert.equal(error, undefined);
  assert.equal(value.status, 'active');
  assert.equal(value.page, 1);
  assert.equal(value.limit, 10);
  assert.equal(value.search, '');
  assert.equal(value.sort, 'name');
  assert.equal(value.order, 'asc');
});

test('query menolak halaman tidak valid', () => {
  const { error } = listClientsQuery.validate({ page: 'abc' });
  assert.ok(error);
});

test('query menolak limit di luar batas', () => {
  const { error } = listClientsQuery.validate({ limit: 1000 });
  assert.ok(error);
});

test('query menolak kolom sort di luar whitelist', () => {
  const { error } = listClientsQuery.validate({ sort: 'password_hash' });
  assert.ok(error);
});

test('query menolak arah urutan di luar whitelist', () => {
  const { error } = listClientsQuery.validate({ order: 'random' });
  assert.ok(error);
});

test('query menerima pencarian dan membatasi panjangnya', () => {
  const { error, value } = listClientsQuery.validate({ search: 'klien demo' });
  assert.equal(error, undefined);
  assert.equal(value.search, 'klien demo');

  const tooLong = listClientsQuery.validate({ search: 'x'.repeat(101) });
  assert.ok(tooLong.error);
});
