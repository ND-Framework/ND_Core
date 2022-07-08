$(function() {
    function display(bool) {
        if (bool) {
            $("#overlay").show();
        } else {
            $("#overlay").hide();
        }
    }
    function atmDisplay(bool) {
        if (bool) {
            $("#atm").show();
            $("#loader, #confirmationScreen, #successScreen, #failedScreen").hide();
            return;
        }
        $("#atm").hide();
    }
    function loader(bool) {
        if (bool) {
            $("#loader").show();
            $("#atm, #confirmationScreen, #successScreen, #failedScreen").hide();
            return;
        }
        $("#loader").hide();
    }
    function confirmationScreen(bool) {
        if (bool) {
            $("#confirmationScreen").show();
            $("#atm, #loader, #successScreen, #failedScreen").hide();
            return;
        }
        $("#confirmationScreen").hide();
    }
    function successScreen(bool) {
        if (bool) {
            $("#successScreen").show()
            $("#confirmationScreen, #atm, #loader, #failedScreen").hide();
            return;
        }
        $("#successScreen").hide();
    }
    function failedScreen(bool) {
        if (bool) {
            $("#failedScreen").show()
            $("#confirmationScreen, #atm, #loader, #successScreen").hide();
            return;
        }
        $("#failedScreen").hide();
    }
    display(false);
    atmDisplay(true);
    loader(false);
    confirmationScreen(false);
    successScreen(false);

    const today = new Date();
    let action;

    window.addEventListener("message", function(event) {
        const item = event.data;
        $("#balance").text(item.balance);
        if (item.status) {
            display(true);
            $("#playername").text(item.playerName);
            $("#date").text(`${item.date}, ${today.toLocaleDateString("en-US", {year: "numeric", month: "long", day: "numeric"})}`);
            $("#time").text(item.time);
        } else if (item.status === false) {
            display(false);
        }
        if (item.success) {
            loader(false);
            successScreen(true);
        } else if (item.success === false) {
            loader(false);
            failedScreen(true);
        }
    })

    $("button[type=submit]").click(function () {
        action = $(this).text();
    });

    $("#confirmButton").click(function() {
        $.post(`https://${GetParentResourceName()}/sound`);
        confirmationScreen(false);
        loader(true);
        $.post(`https://${GetParentResourceName()}/useATM`, JSON.stringify({
            action: action,
            amount: $("#enteredAmount").val(),
            transferAmount: $("#transferAmount").val(),
            transferTarget: $("#transferTarget").val()
        }));
        $("#enteredAmount").val("");
        $("#transferAmount").val("");
        $("#transferTarget").val("");
        return false;
    })

    $("#cancelButton").click(function() {
        $.post(`https://${GetParentResourceName()}/sound`);
        confirmationScreen(false);
        loader(true);
        setTimeout(() => {
            loader(false);
            atmDisplay(true);
        }, 300);
        return false;
    })

    $("#atm").submit(function() {
        $.post(`https://${GetParentResourceName()}/sound`);
        atmDisplay(false);
        loader(true);
        setTimeout(() => {
            loader(false);
            confirmationScreen(true);
        }, 300);
        return false;
    })

    $(".mainMenuButton").click(function() {
        $.post(`https://${GetParentResourceName()}/sound`);
        successScreen(false);
        failedScreen(false);
        loader(true);
        setTimeout(() => {
            loader(false);
            atmDisplay(true);
        }, 300);
        return false;
    })

    $("#closeButton").click(function() {
        $.post(`https://${GetParentResourceName()}/close`);
        return;
    })
});