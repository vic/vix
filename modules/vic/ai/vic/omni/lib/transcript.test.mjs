// transcript.test.mjs — plain node asserts, no framework, <1s
import { parseLine } from './transcript.js';
import assert from 'node:assert/strict';

// Helper: normalize a minimal message object
function make(role, content, extra = {}) {
  return {
    type: role === 'user' ? 'user' : 'assistant',
    uuid: 'test-uuid',
    sessionId: 'test-session',
    timestamp: '2026-01-01T00:00:00.000Z',
    message: { role, content },
    ...extra,
  };
}

// 1. NORMAL text message — must still extract text unchanged
{
  const ev = parseLine(JSON.stringify(make('assistant', [{ type: 'text', text: 'Hello world' }])));
  assert.ok(ev && ev.ok, 'normal text: ev.ok');
  assert.ok(ev.text.includes('Hello world'), `normal text: got "${ev.text}"`);
  assert.equal(ev.errors, 0, 'normal text: no errors');
}

// 2. Error tool_result with STRING content — text must include error message
{
  const ev = parseLine(JSON.stringify(make('user', [
    { type: 'tool_result', is_error: true, content: 'ENOENT: cannot open /tmp/z no such file', tool_use_id: 'tid1' }
  ])));
  assert.ok(ev && ev.ok, 'str error: ev.ok');
  assert.ok(ev.text.includes('ENOENT'), `str error: text should include ENOENT, got "${ev.text}"`);
  assert.ok(ev.errors >= 1, `str error: errors should be >=1, got ${ev.errors}`);
}

// 3. Error tool_result with ARRAY content — text must include sub-block text
{
  const ev = parseLine(JSON.stringify(make('user', [
    { type: 'tool_result', is_error: true, content: [{ type: 'text', text: 'boom' }], tool_use_id: 'tid2' }
  ])));
  assert.ok(ev && ev.ok, 'arr error: ev.ok');
  assert.ok(ev.text.includes('boom'), `arr error: text should include boom, got "${ev.text}"`);
  assert.ok(ev.errors >= 1, `arr error: errors should be >=1, got ${ev.errors}`);
}

// 4. Non-error tool_result — text extracted but no ERROR prefix needed; errors stays 0
{
  const ev = parseLine(JSON.stringify(make('user', [
    { type: 'tool_result', is_error: false, content: 'ok result text', tool_use_id: 'tid3' }
  ])));
  assert.ok(ev && ev.ok, 'non-error tool_result: ev.ok');
  assert.ok(ev.text.includes('ok result text'), `non-error tool_result: text should include result, got "${ev.text}"`);
  assert.equal(ev.errors, 0, 'non-error tool_result: errors should be 0');
}

// 5. Mixed message: text block + error tool_result — both appear in text
{
  const ev = parseLine(JSON.stringify(make('user', [
    { type: 'text', text: 'user message' },
    { type: 'tool_result', is_error: true, content: 'ENOENT: file missing', tool_use_id: 'tid4' }
  ])));
  assert.ok(ev && ev.ok, 'mixed: ev.ok');
  assert.ok(ev.text.includes('user message'), `mixed: should include text block, got "${ev.text}"`);
  assert.ok(ev.text.includes('ENOENT'), `mixed: should include error text, got "${ev.text}"`);
  assert.ok(ev.errors >= 1, `mixed: errors should be >=1, got ${ev.errors}`);
}

// 6. n_errors counts CORRECTLY even when tool_result has null/empty content
{
  const ev = parseLine(JSON.stringify(make('user', [
    { type: 'tool_result', is_error: true, content: null, tool_use_id: 'tid5' },
    { type: 'tool_result', is_error: true, content: '', tool_use_id: 'tid6' },
  ])));
  assert.ok(ev && ev.ok, 'null content: ev.ok');
  assert.equal(ev.errors, 2, `null content: errors should be 2, got ${ev.errors}`);
}

console.log('PASS');
