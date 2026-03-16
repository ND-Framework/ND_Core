export function fetchCallback(name, data, cb) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => {
        if (cb) cb(resp);
    });
}
