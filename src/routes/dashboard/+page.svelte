<script>
  import { auth } from '$lib/stores/auth.js';
  import { onMount } from 'svelte';
  import { listSubmissions, updateSubmission, deleteSubmission } from '$lib/db/pouch.js';

  let loading = true;
  let items = [];
  let error = '';

  async function load() {
    loading = true;
    error = '';
    try {
      items = await listSubmissions();
    } catch (e) {
      console.error(e);
      error = 'Failed to load submissions';
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    if (!$auth.loggedIn) {
      window.location.href = '/login';
      return;
    }
    load();
  });

  const canEdit = () => $auth.role === 'admin';

  async function toggleApprove(item) {
    if (!canEdit()) return;
    item.status = item.status === 'approved' ? 'pending' : 'approved';
    await updateSubmission(item);
    await load();
  }

  async function saveEdits(item) {
    if (!canEdit()) return;
    await updateSubmission(item);
    await load();
  }

  async function remove(item) {
    if (!canEdit()) return;
    if (!confirm('Delete this record?')) return;
    await deleteSubmission(item);
    await load();
  }
</script>

<section class="wrap">
  <h1>Dashboard</h1>
  {#if loading}
    <p>Loading…</p>
  {:else if error}
    <p class="error">{error}</p>
  {:else if items.length === 0}
    <p>No submissions yet.</p>
  {:else}
    <div class="list">
      {#each items as item (item._id)}
        <article class="card">
          <header class="card-h">
            <div class="meta">
              <strong>{item.fields.fullName || 'No name'}</strong>
              <span class="status {item.status}">{item.status}</span>
              <span class="date">{new Date(item.createdAt).toLocaleString()}</span>
            </div>
            {#if canEdit()}
              <div class="actions">
                <button class="btn alt" onclick={() => toggleApprove(item)}>
                  {item.status === 'approved' ? 'Mark Pending' : 'Approve'}
                </button>
                <button class="btn danger" onclick={() => remove(item)}>Delete</button>
              </div>
            {/if}
          </header>

          <div class="grid">
            <label>
              <span>Email</span>
              <input bind:value={item.fields.email} disabled={!canEdit()} />
            </label>
            <label>
              <span>Phone</span>
              <input bind:value={item.fields.phone} disabled={!canEdit()} />
            </label>
            <label>
              <span>Address</span>
              <input bind:value={item.fields.address} disabled={!canEdit()} />
            </label>
            <label>
              <span>City</span>
              <input bind:value={item.fields.city} disabled={!canEdit()} />
            </label>
            <label>
              <span>State</span>
              <input bind:value={item.fields.state} disabled={!canEdit()} />
            </label>
            <label>
              <span>ZIP</span>
              <input bind:value={item.fields.zip} disabled={!canEdit()} />
            </label>
          </div>

          <label>
            <span>Notes</span>
            <textarea rows="2" bind:value={item.fields.notes} disabled={!canEdit()}></textarea>
          </label>

          {#if canEdit()}
            <div class="row">
              <button class="btn" onclick={() => saveEdits(item)}>Save changes</button>
            </div>
          {/if}
        </article>
      {/each}
    </div>
  {/if}
</section>

<style>
  .wrap { max-width: 960px; margin: 1rem auto; padding: 0 1rem; }
  .list { display: grid; gap: 1rem; }
  .card { background:#0b1220; color:#e5e7eb; border:1px solid #1f2937; padding:1rem; border-radius:10px; display:grid; gap:0.75rem; }
  .card-h { display:flex; align-items:center; justify-content:space-between; gap:0.75rem; flex-wrap: wrap; }
  .meta { display:flex; gap:0.5rem; align-items:center; flex-wrap: wrap; }
  .status { font-size:0.75rem; padding:0.15rem 0.5rem; border-radius:999px; background:#334155; text-transform:capitalize; }
  .status.approved { background:#064e3b; color:#a7f3d0; }
  .date { color:#94a3b8; font-size:0.85rem; }
  .actions { display:flex; gap:0.5rem; }
  .grid { display:grid; gap: 0.75rem; grid-template-columns: repeat(3,1fr); }
  label { display:grid; gap:0.25rem; }
  input, textarea { padding:0.6rem 0.75rem; border-radius:8px; border:1px solid #334155; background:#111827; color:#e5e7eb; }
  .row { display:flex; justify-content:flex-end; }
  .btn { padding:0.5rem 0.7rem; background:#2563eb; color:#fff; border:none; border-radius:8px; cursor:pointer; }
  .btn.alt { background:#0ea5e9; }
  .btn.danger { background:#ef4444; }
  .btn:hover { filter: brightness(0.95); }
  .error { color:#fca5a5; }
  @media (max-width: 800px) { .grid { grid-template-columns: 1fr; } }
</style>
