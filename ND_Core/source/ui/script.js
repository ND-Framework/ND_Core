$(function() {
    let displayOn = true

    // Hide/show ui function
    function display(bool) {
        if (bool) {
            displayOn = true
            $("body").show();
            Money(false)
        } else {
            displayOn = false
            $("body").hide();
        }
    }
    function characterCreatorMenu(bool) {
        if (bool) {
            $("#characterCreator").fadeIn("slow");
            $("#characterEditor").hide();
            $("#exitGameMenu").hide();
            $("#deleteCharacterMenu").hide();
            $("#spawnLocation").hide();
        } else {
            $("#characterCreator").fadeOut("slow");
        }
    }
    function characterEditorMenu(bool) {
        if (bool) {
            $("#characterCreator").hide();
            $("#characterEditor").fadeIn("slow");
            $("#exitGameMenu").hide();
            $("#deleteCharacterMenu").hide();
            $("#spawnLocation").hide();
        } else {
            $("#characterEditor").fadeOut("slow");
        }
    }
    function exitGameMenu(bool) {
        if (bool) {
            $("#characterCreator").hide();
            $("#characterEditor").hide();
            $("#exitGameMenu").fadeIn("slow");
            $("#deleteCharacterMenu").hide();
            $("#spawnLocation").hide();
        } else {
            $("#exitGameMenu").fadeOut("slow");
        }
    }
    function confirmDeleteMenu(bool) {
        if (bool) {
            $("#characterCreator").hide();
            $("#characterEditor").hide();
            $("#exitGameMenu").hide();
            $("#deleteCharacterMenu").fadeIn("slow");
            $("#spawnLocation").hide();
        } else {
            $("#deleteCharacterMenu").fadeOut("slow");
        }
    }
    function spawnMenu(bool) {
        if (bool) {
            $("#characterCreator").hide();
            $("#characterEditor").hide();
            $("#exitGameMenu").hide();
            $("#deleteCharacterMenu").hide();
            $("#spawnLocation").fadeIn("slow");
        } else {
            $("#spawnLocation").fadeOut("slow");
        }
    }
    function Money(bool) {
        if (bool) {
            $("#money").show();
            $("body").css("background-image", "none");
            $("body").show();
            if (displayOn === false) {
                $("#overlay").hide();
            }
        } else {
            $("#money").hide();
            $("#overlay").show();
        }
    }
    display(false)
    characterCreatorMenu(false)
    characterEditorMenu(false)
    exitGameMenu(false)
    confirmDeleteMenu(false)
    spawnMenu(false)
    Money(false)

    window.addEventListener('message', function(event) {
        const item = event.data;
        if (item.type === "ui") {
            if (item.status) {
                $('#serverName').text(item.serverName);
                $("body").css("background-image", "url(" + item.background + ")");
                display(true)
            } else {
                display(false)
            }
        }
        
        $('#playerAmount').text(item.characterAmount);

        if (item.type === "character") {
            characterCreatorMenu(false)
            createCharacter(item.firstName, item.lastName, item.dateOfBirth, item.gender, item.twtName, item.department, item.startingCash, item.startingBank, item.id)
        }

        if (item.type === "setSpawns") {
            createSpawnButtons(item.x, item.y, item.z, item.name)
        }

        if (item.type === "givePerms") {
            $('.departments').append($('<option>', {
                text: item.deptRole
            }));
        }

        if (item.type === "aop") {
            $("#aop").text(item.aop);
        }

        if (item.type === "Money") {
            Money(true)
            $("#cash").text(item.cash);
            $("#bank").text(item.bank);
        }

        if (item.type === "onStart" && item.enableMoneySystem === true) {
            $("#characterInfoContainerLeft").append('<label class="fourthRowText" for="startingcash">Cash</label><br><input id="startingCash" class="fourthRowInput" type="number" pattern="[0-9]+" placeholder="$2500" name="startingcash" required>');
            $("#characterInfoContainerRight").append('<label class="fourthRowText" for="startingbank">Bank</label><br><input id="startingBank" class="fourthRowInput" type="number" pattern="[0-9]+" placeholder="$8000" name="startingbank" style="width: 93%;" required>');
            $("#startingBank").attr({
                "max": item.maxStartingBank,
            });
            $("#startingCash").attr({
                "max": item.maxStartingCash,
            });
        }

        if (item.type === "refresh") {
            $("#charactersSection").empty();
        }
    })

    function createCharacter(firstName, lastName, dateOfBirth, gender, twtName, department, startingCash, startingBank, id) {
        $("#charactersSection").append('<button id="characterButton' + id + '" class="createdButton" style="text-transform: capitalize;">' + firstName + " " + lastName + " (" + department +')</button><button id="characterButtonEdit' + id + '" class="createdButtonEdit"><a class="fas fa-edit"></a> Edit</button><button id="characterButtonDelete' + id + '" class="createdButtonDelete"><a class="fas fa-trash-alt"></a> Delete</button>');
        $("#characterButton" + id).click(function() {
            spawnMenu(true)
            $.post(`https://${GetParentResourceName()}/setMainCharacter`, JSON.stringify({
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                gender: gender,
                twtName: twtName,
                department: department,
                startingCash: startingCash,
                startingBank: startingBank,
                character: id
            }));
            return
        })
        $("#characterButtonEdit" + id).click(function() {
            characterEditorMenu(true)
            characterEdited = id
            return
        })
        $("#characterButtonDelete" + id).click(function() {
            confirmDeleteMenu(true)
            characterDeleting = id
            return
        })
    }

    function createSpawnButtons(x, y, z, name) {
        $("#spawnMenuContainer").empty();
        setTimeout(function(){
            $("#spawnMenuContainer").append(`<button class="spawnButtons" id="${x}, ${y}, ${z}, ${name}" onclick='tp("${x}", "${y}", "${z}", "${name}")' > ${name} </button>`);
        }, 10);
    }

    $("#characterCreator").submit(function() {
        $.post(`https://${GetParentResourceName()}/newCharacter`, JSON.stringify({
            firstName: $("#firstName").val(),
            lastName: $("#lastName").val(),
            dateOfBirth: $("#dateOfBirth").val(),
            gender: $("#gender").val(),
            twtName: $("#twtName").val(),
            department: $("#department").val(),
            startingCash: $("#startingCash").val(),
            startingBank: $("#startingBank").val()
        }));
        characterCreatorMenu(false)
        $("#firstName, #lastName, #dateOfBirth, #twtName, #startingCash, #startingBank").val("")
        return false
    })

    $("#characterEditor").submit(function() {
        characterEditorMenu(false)
        $.post(`https://${GetParentResourceName()}/editCharacter`, JSON.stringify({
            firstName: $("#newFirstName").val(),
            lastName: $("#newLastName").val(),
            dateOfBirth: $("#newDateOfBirth").val(),
            gender: $("#newGender").val(),
            twtName: $("#newTwtName").val(),
            department: $("#newDepartment").val(),
            id: characterEdited
        }));
        $("#characterButton" + characterEdited).text($("#newFirstName").val() + " " + $("#newLastName").val() + " (" + $("#newDepartment").val() + ")");
        return false
    })

    $("#deleteCharacterConfirm").click(function() {
        confirmDeleteMenu(false)
        $("#characterButton" + characterDeleting).fadeOut("slow",function(){
            $("#characterButton" + characterDeleting).remove();
        })
        $("#characterButtonEdit" + characterDeleting).fadeOut("slow",function(){
            $("#characterButtonEdit" + characterDeleting).remove();
        })
        $("#characterButtonDelete" + characterDeleting).fadeOut("slow",function(){
            $("#characterButtonDelete" + characterDeleting).remove();
        })
        $.post(`https://${GetParentResourceName()}/delCharacter`, JSON.stringify({
            character: characterDeleting
        }));
        return
    })

    $("#newCharacterButton").click(function() {
        characterCreatorMenu(true)
        return
    })

    $("#deleteCharacterCancel").click(function() {
        confirmDeleteMenu(false)
        return
    })
    $("#cancelCharacterCreation").click(function() {
        characterCreatorMenu(false)
        return
    })
    $("#cancelCharacterEditing").click(function() {
        characterEditorMenu(false)
        return
    })

    $("#tpCancel").click(function() {
        spawnMenu(false)
        setTimeout(function(){
            $("#spawnMenuContainer").empty();
        }, 550);
        return
    })
    $("#tpDoNot").click(function() {
        $.post(`https://${GetParentResourceName()}/tpDoNot`);
        spawnMenu(false)
        setTimeout(function(){
            $("#spawnMenuContainer").empty();
        }, 550);
        return
    })

    $("#quitGameButton").click(function() {
        exitGameMenu(true)
        return
    })
    $("#exitGameCancel").click(function() {
        exitGameMenu(false)
        return
    })
    $("#exitGameConfirm").click(function() {
        $.post(`https://${GetParentResourceName()}/exitGame`);
        return
    })
});
