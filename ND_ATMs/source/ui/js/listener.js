$(function() {
    let deposit = false
    let withdraw = false

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
            $("#loader").hide();
            $("#confirmationScreen").hide();
            $("#successScreen").hide()
        } else {
            $("#atm").hide();
        }
    }
    function loader(bool) {
        if (bool) {
            $("#loader").show();
            $("#atm").hide();
            $("#confirmationScreen").hide();
            $("#successScreen").hide()
        } else {
            $("#loader").hide();
        }
    }
    function confirmationScreen(bool) {
        if (bool) {
            $("#confirmationScreen").show();
            $("#atm").hide();
            $("#loader").hide();
            $("#successScreen").hide()
        } else {
            $("#confirmationScreen").hide();
        }
    }
    function successScreen(bool) {
        if (bool) {
            $("#successScreen").show()
            $("#confirmationScreen").hide();
            $("#atm").hide();
            $("#loader").hide();
        } else {
            $("#successScreen").hide()
        }
    }
    display(false)
    atmDisplay(true)
    loader(false)
    confirmationScreen(false)
    successScreen(false)

    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const d = new Date();

    window.addEventListener("message", function(event) {
        const item = event.data;
        if (item.status) {
            display(true)
            $("#playername").text(item.playerName)
            $("#balance").text(item.balance)
            $("#date").text(item.date + ", " + months[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear())
            $("#time").text(item.time)
        } else {
            display(false)
        }
    })

    $("#withdrawButton").click(function() {
        withdraw = true
        $.post("https://ND_ATMs/sound", JSON.stringify({}));
        atmDisplay(false)
        loader(true)
        setTimeout(() => {
            loader(false)
            confirmationScreen(true)
        }, 400);
        return false
    })

    $("#depositButton").click(function() {
        deposit = true
        $.post("https://ND_ATMs/sound", JSON.stringify({}));
        atmDisplay(false)
        loader(true)
        setTimeout(() => {
            loader(false)
            confirmationScreen(true)
        }, 400);
        return false
    })

    $("#cancelButton").click(function() {
        withdraw = false
        deposit = false
        $.post("https://ND_ATMs/sound", JSON.stringify({}));
        confirmationScreen(false)
        loader(true)
        setTimeout(() => {
            loader(false)
            atmDisplay(true)
        }, 300);
        return false
    })

    $("#atm").submit(function() {
        $.post("https://ND_ATMs/sound", JSON.stringify({}));
        confirmationScreen(false)
        loader(true)
        setTimeout(() => {
            loader(false)
            if (withdraw) {
                $.post("https://ND_ATMs/withdraw", JSON.stringify({
                    amount: $("#enteredAmount").val()
                }));
            } else if (deposit) {
                $.post("https://ND_ATMs/deposit", JSON.stringify({
                    amount: $("#enteredAmount").val()
                }));
            }
            withdraw = false
            deposit = false
            successScreen(true)
        }, 2500);
        return false
    })

    $("#mainMenuButton").click(function() {
        $.post("https://ND_ATMs/sound", JSON.stringify({}));
        successScreen(false)
        loader(true)
        setTimeout(() => {
            loader(false)
            atmDisplay(true)
        }, 300);
        return false
    })

    $("#closeButton").click(function() {
        $.post("https://ND_ATMs/close", JSON.stringify({}));
        return
    })
});
