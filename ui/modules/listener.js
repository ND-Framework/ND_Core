const nuiMessages = {};

window.addEventListener("message", function(event) {
    const item = event.data;
    const listener = nuiMessages[item.type];
    if (!listener) return;
    for (let i = 0; i < listener.length; i++) {
        listener[i](item);
    }
});

export function nuiMessage(name, cb) {
    if (!nuiMessages[name]) nuiMessages[name] = [];
    nuiMessages[name].push(cb);
}
