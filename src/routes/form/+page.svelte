<script>
  import { auth } from '$lib/stores/auth.js';
  import { saveSubmission } from '$lib/db/pouch.js';
  import { onMount } from 'svelte';

  let submitting = false;
  let message = '';

  // 8 input fields
  let form = {
    fullName: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    state: '',
    zip: '',
    notes: ''
  };

  onMount(() => {
    if (!$auth.loggedIn) {
      window.location.href = '/login';
    }
  });

  async function submit(e) {
    e.preventDefault();
    submitting = true;
    message = '';
    try {
      await saveSubmission(form);
      message = 'Saved locally. Will sync when online.';
      // reset
      form = { fullName: '', email: '', phone: '', address: '', city: '', state: '', zip: '', notes: '' };
    } catch (e) {
      console.error(e);
      message = 'Failed to save';
    } finally {
      submitting = false;
    }
  }
</script>

<section class="wrap">
  <h1>User Form</h1>
  <form class="card" onsubmit={submit}>
    <label>
      <span>Full name</span>
      <input required bind:value={form.fullName} placeholder="John Doe" />
    </label>
    <label>
      <span>Email</span>
      <input type="email" required bind:value={form.email} placeholder="john@example.com" />
    </label>
    <label>
      <span>Phone</span>
      <input required bind:value={form.phone} placeholder="+123456789" />
    </label>
    <label>
      <span>Address</span>
      <input required bind:value={form.address} placeholder="123 Main St" />
    </label>
    <div class="grid">
      <label>
        <span>City</span>
        <input required bind:value={form.city} />
      </label>
      <label>
        <span>State</span>
        <input required bind:value={form.state} />
      </label>
      <label>
        <span>ZIP</span>
        <input required bind:value={form.zip} />
      </label>
    </div>
    <label>
      <span>Notes</span>
      <textarea rows="3" bind:value={form.notes} placeholder="Optional notes"></textarea>
    </label>

    <button class="btn" type="submit" disabled={submitting}>{submitting ? 'Saving…' : 'Save'}</button>
    {#if message}
      <div class="msg">{message}</div>
    {/if}
  </form>
</section>

<style>
  .wrap { max-width: 720px; margin: 1rem auto; padding: 0 1rem; }
  h1 { margin-bottom: 0.5rem; }
  .card { display:grid; gap:0.75rem; background:#0b1220; color:#e5e7eb; border:1px solid #1f2937; padding:1rem; border-radius:10px; }
  label { display:grid; gap:0.25rem; }
  input, textarea { padding:0.6rem 0.75rem; border-radius:8px; border:1px solid #334155; background:#111827; color:#e5e7eb; }
  .btn { padding:0.6rem 0.75rem; background:#2563eb; color:#fff; border:none; border-radius:8px; cursor:pointer; width:fit-content; }
  .btn[disabled] { opacity: 0.6; cursor: not-allowed; }
  .msg { color:#a7f3d0; }
  .grid { display:grid; gap:0.75rem; grid-template-columns: repeat(3, 1fr); }
  @media (max-width: 640px) {
    .grid { grid-template-columns: 1fr; }
  }
</style>
