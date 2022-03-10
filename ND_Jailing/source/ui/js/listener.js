$(document).ready(function() {
    function display(bool) {
        if (bool) {
            $("#overlay").fadeIn("slow");
        } else {
            $("#overlay").fadeOut("slow");
        }
    }
    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }

        $("#error").text(item.error);

        if (item.type === "players") {
            $("#id").append($("<option>", {
                text: item.players
            }));
        }

        if (item.type === "clean") {
            $("#id").empty();
            $("#overlay").reset();
        }
    })

    $("#overlay").submit(function() {
        let id = $("#id").val();
        let time = $("#time").val();
        let reason = $("#reason").val();
        $.post(`https://${GetParentResourceName()}/sumbit`, JSON.stringify({
            id: id,
            time: time,
            reason: reason
        }));
        return false
    })

    $(".resetButton").click(function() {
        $.post(`https://${GetParentResourceName()}/closeUI`);
        $("#id").empty();
        return
    })
    
    document.onkeyup = function(data) {
        if (data.which == 27) {
            $.post(`https://${GetParentResourceName()}/closeUI`);
            $("#id").empty();
            return
        }
    };
});