import van from "https://cdn.jsdelivr.net/gh/vanjs-org/van/public/van-1.5.3.min.js";
import { nuiMessage } from "./modules/listener.js";
import { fetchCallback } from "./modules/fetch.js";
import { closeUI, setOpen } from "./modules/close.js";

const { div, h1, h2, h3, p, button, input, label, span, i: icon } = van.tags;

let groups = [];
let container = null;
let editPanel = null;
let currentEdit = null;

function createGroupCard(group) {
    const card = div({ class: "group-card", onclick: () => openEditPanel(group) },
        div({ class: "group-card-header" },
            h3(group.label),
            span({ class: "group-name" }, group.name)
        ),
        div({ class: "group-card-tags" },
            group.isJob ? span({ class: "tag tag-job" }, "Job") : null,
            span({ class: "tag tag-ranks" }, `${group.ranks.length} rank${group.ranks.length !== 1 ? "s" : ""}`)
        )
    );
    return card;
}

function renderGroupList() {
    if (!container) return;
    container.innerHTML = "";

    const header = div({ class: "list-header" },
        h1("Group Management"),
        button({ class: "btn btn-create", onclick: () => openCreatePanel() },
            icon({ class: "fa-solid fa-plus" }),
            " New Group"
        )
    );
    container.appendChild(header);

    const searchRow = div({ class: "search-row" },
        input({ class: "search-input", type: "text", placeholder: "Search groups...", oninput: (e) => filterGroups(e.target.value) })
    );
    container.appendChild(searchRow);

    const grid = div({ class: "group-grid", id: "group-grid" });
    groups.forEach(g => grid.appendChild(createGroupCard(g)));
    container.appendChild(grid);
}

function filterGroups(query) {
    const grid = document.getElementById("group-grid");
    if (!grid) return;
    grid.innerHTML = "";
    const lower = query.toLowerCase();
    const filtered = groups.filter(g => g.name.toLowerCase().includes(lower) || g.label.toLowerCase().includes(lower));
    filtered.forEach(g => grid.appendChild(createGroupCard(g)));
}

function createRankRow(rank, index, ranksList) {
    const row = div({ class: "rank-row", "data-index": index },
        div({ class: "rank-order" },
            button({ class: "btn-icon", title: "Move up", onclick: () => moveRank(ranksList, index, -1) },
                icon({ class: "fa-solid fa-chevron-up" })
            ),
            span({ class: "rank-weight" }, String(rank.weight)),
            button({ class: "btn-icon", title: "Move down", onclick: () => moveRank(ranksList, index, 1) },
                icon({ class: "fa-solid fa-chevron-down" })
            )
        ),
        input({ class: "rank-label-input", type: "text", value: rank.label, placeholder: "Rank label", oninput: (e) => {
            ranksList[index].label = e.target.value;
        }}),
        div({ class: "rank-boss-toggle" },
            label({ class: "checkbox-label" },
                input({ type: "checkbox", checked: rank.isBoss, onchange: (e) => {
                    ranksList[index].isBoss = e.target.checked;
                }}),
                " Boss"
            )
        ),
        button({ class: "btn-icon btn-danger", title: "Delete rank", onclick: () => {
            ranksList.splice(index, 1);
            recalculateWeights(ranksList);
            rerenderRanks(ranksList);
        }},
            icon({ class: "fa-solid fa-trash" })
        )
    );
    return row;
}

function moveRank(ranksList, index, direction) {
    const newIndex = index + direction;
    if (newIndex < 0 || newIndex >= ranksList.length) return;
    const temp = ranksList[index];
    ranksList[index] = ranksList[newIndex];
    ranksList[newIndex] = temp;
    recalculateWeights(ranksList);
    rerenderRanks(ranksList);
}

function recalculateWeights(ranksList) {
    for (let i = 0; i < ranksList.length; i++) {
        ranksList[i].weight = i + 1;
    }
}

function rerenderRanks(ranksList) {
    const ranksContainer = document.getElementById("ranks-container");
    if (!ranksContainer) return;
    ranksContainer.innerHTML = "";
    ranksList.forEach((rank, idx) => {
        ranksContainer.appendChild(createRankRow(rank, idx, ranksList));
    });
}

function openEditPanel(group) {
    currentEdit = JSON.parse(JSON.stringify(group));
    showEditPanel(false);
}

function openCreatePanel() {
    currentEdit = { name: "", label: "", isJob: false, ranks: [] };
    showEditPanel(true);
}

function showEditPanel(isNew) {
    if (!editPanel) return;
    editPanel.innerHTML = "";
    editPanel.classList.add("open");

    const ranksList = currentEdit.ranks.map(r => ({ ...r }));

    const panelContent = div({ class: "edit-content" },
        div({ class: "edit-header" },
            h2(isNew ? "Create Group" : "Edit Group"),
            button({ class: "btn-icon", onclick: () => closeEditPanel() },
                icon({ class: "fa-solid fa-xmark" })
            )
        ),
        div({ class: "edit-form" },
            div({ class: "form-group" },
                label("Name (unique key)"),
                input({
                    class: "form-input",
                    type: "text",
                    value: currentEdit.name,
                    disabled: !isNew,
                    placeholder: "e.g. polis",
                    oninput: (e) => { currentEdit.name = e.target.value.toLowerCase().replace(/[^a-z0-9_-]/g, ""); e.target.value = currentEdit.name; }
                })
            ),
            div({ class: "form-group" },
                label("Label"),
                input({
                    class: "form-input",
                    type: "text",
                    value: currentEdit.label,
                    placeholder: "e.g. Polis",
                    oninput: (e) => { currentEdit.label = e.target.value; }
                })
            ),
            div({ class: "form-group form-row" },
                label({ class: "checkbox-label" },
                    input({
                        type: "checkbox",
                        checked: currentEdit.isJob,
                        onchange: (e) => { currentEdit.isJob = e.target.checked; }
                    }),
                    " Is Job"
                )
            ),
            div({ class: "form-group" },
                div({ class: "ranks-header" },
                    h3("Ranks"),
                    button({ class: "btn btn-small", onclick: () => {
                        ranksList.push({ label: "", weight: ranksList.length + 1, isBoss: false });
                        rerenderRanks(ranksList);
                    }},
                        icon({ class: "fa-solid fa-plus" }),
                        " Add Rank"
                    )
                ),
                div({ class: "ranks-info" },
                    p("Rank 1 is the lowest. Higher weight = higher rank. Boss ranks grant boss permissions.")
                ),
                div({ id: "ranks-container", class: "ranks-container" })
            )
        ),
        div({ class: "edit-actions" },
            !isNew ? button({ class: "btn btn-danger", onclick: () => deleteGroup(currentEdit.name) },
                icon({ class: "fa-solid fa-trash" }),
                " Delete Group"
            ) : null,
            div({ class: "edit-actions-right" },
                button({ class: "btn btn-secondary", onclick: () => closeEditPanel() }, "Cancel"),
                button({ class: "btn btn-primary", onclick: () => saveGroup(isNew, ranksList) },
                    icon({ class: "fa-solid fa-floppy-disk" }),
                    " Save"
                )
            )
        )
    );

    editPanel.appendChild(panelContent);
    rerenderRanks(ranksList);
}

function closeEditPanel() {
    if (!editPanel) return;
    editPanel.classList.remove("open");
    editPanel.innerHTML = "";
    currentEdit = null;
}

function saveGroup(isNew, ranksList) {
    if (!currentEdit.name || !currentEdit.label) return;

    const ranks = ranksList.map((r, idx) => ({
        label: r.label,
        weight: idx + 1,
        isBoss: r.isBoss
    }));

    if (isNew) {
        fetchCallback("groups:create", {
            name: currentEdit.name,
            label: currentEdit.label,
            isJob: currentEdit.isJob,
            ranks: ranks
        }, (result) => {
            if (result && result.success) {
                groups = result.groups || groups;
                renderGroupList();
                closeEditPanel();
            }
        });
    } else {
        fetchCallback("groups:edit", {
            name: currentEdit.name,
            label: currentEdit.label,
            isJob: currentEdit.isJob,
            ranks: ranks
        }, (result) => {
            if (result && result.success) {
                groups = result.groups || groups;
                renderGroupList();
                closeEditPanel();
            }
        });
    }
}

function deleteGroup(name) {
    if (!name) return;
    fetchCallback("groups:delete", { name: name }, (result) => {
        if (result && result.success) {
            groups = result.groups || groups;
            renderGroupList();
            closeEditPanel();
        }
    });
}

function init() {
    container = div({ class: "main-page" });
    editPanel = div({ class: "edit-panel" });
    document.body.appendChild(container);
    document.body.appendChild(editPanel);
}

nuiMessage("groups:open", (info) => {
    setOpen(true);
    document.body.style.opacity = "1";
    groups = info.groups || [];
    renderGroupList();
});

nuiMessage("groups:close", () => {
    closeUI();
});

init();
