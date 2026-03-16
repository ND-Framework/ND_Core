import { fetchCallback } from "./fetch.js";

let isOpen = false;

export function closeUI() {
    if (!isOpen) return;
    isOpen = false;
    document.body.style.opacity = "0";
    setTimeout(() => {
        fetchCallback("hide");
    }, 400);
}

export function setOpen(state) {
    isOpen = state;
}

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeUI();
});

document.addEventListener("click", (event) => {
    const mainPage = document.querySelector(".main-page");
    const editPanel = document.querySelector(".edit-panel");
    if (!mainPage || !editPanel) return;

    const mainRect = mainPage.getBoundingClientRect();
    const editRect = editPanel.getBoundingClientRect();

    const insideMainPage =
        event.clientX >= mainRect.left &&
        event.clientX <= mainRect.right &&
        event.clientY >= mainRect.top &&
        event.clientY <= mainRect.bottom;

    const insideEditPanel =
        event.clientX >= editRect.left &&
        event.clientX <= editRect.right &&
        event.clientY >= editRect.top &&
        event.clientY <= editRect.bottom;

    if (!insideMainPage && !insideEditPanel) {
        closeUI();
    }
});

