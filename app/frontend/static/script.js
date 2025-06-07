API_BASE = null
title = ""

async function fetchBaseAPI() {
  if (API_BASE == null) {
    const response = await fetch('/static/config.json');
    const config = await response.json();
    API_BASE = config.API;
  }
}

async function refreshTitle() {
  try {
    const res = await fetch(`${API_BASE}/title`);
    const json = await res.json();
    title = json.data.message;
    document.querySelector("#title").innerHTML = title;
  } catch (err) {
    console.error("Failed to load title:", err);
  }
}

async function fetchUsers() {
  try {
    const res = await fetch(`${API_BASE}/users`);
    const json = await res.json();
    const tbody = document.querySelector("#users-table tbody");
    tbody.innerHTML = "";

    json.data.forEach(user => {
      const row = `<tr>
        <td>${user.id}</td>
        <td>${user.name}</td>
        <td>${user.email}</td>
      </tr>`;
      tbody.insertAdjacentHTML('beforeend', row);
    });
  } catch (err) {
    console.error("Failed to load users:", err);
  }
}

async function sendSQS() {
  try {
    const res = await fetch(`${API_BASE}/send-sqs`, { method: "POST" });
    const json = await res.json();
    alert(json.data?.message || "Message sent!");
  } catch (err) {
    alert("Failed to send to SQS");
    console.error(err);
  }
}

async function triggerDebug() {
  try {
    const res = await fetch(`${API_BASE}/debug`);
    const json = await res.json();
    alert(json.data?.message || "Debug triggered!");
  } catch (err) {
    alert("Debug failed");
    console.error(err);
  }
}

fetchBaseAPI()
refreshTitle()
fetchUsers();
