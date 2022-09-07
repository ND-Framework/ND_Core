$(function() {
    function display(bool) {
        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
        }
    }
    function characterCreatorMenu(bool) {
        if (bool) {
            $("#characterCreator").fadeIn("slow");
            $("#characterEditor, #exitGameMenu, #deleteCharacterMenu, #spawnLocation").hide();
            return;
        }
        $("#characterCreator").fadeOut("slow");
    }
    function characterEditorMenu(bool) {
        if (bool) {
            $("#characterEditor").fadeIn("slow");
            $("#characterCreator, #exitGameMenu, #deleteCharacterMenu, #spawnLocation").hide();
            return;
        }
        $("#characterEditor").fadeOut("slow");
    }
    function exitGameMenu(bool) {
        if (bool) {
            $("#exitGameMenu").fadeIn("slow");
            $("#characterCreator, #characterEditor, #deleteCharacterMenu, #spawnLocation").hide();
            return;
        }
        $("#exitGameMenu").fadeOut("slow");
    }
    function confirmDeleteMenu(bool) {
        if (bool) {
            $("#deleteCharacterMenu").fadeIn("slow");
            $("#characterCreator, #characterEditor, #exitGameMenu, #spawnLocation").hide();
            return;
        }
        $("#deleteCharacterMenu").fadeOut("slow");
    }
    function spawnMenu(bool) {
        if (bool) {
            $("#spawnLocation").fadeIn("slow");
            $("#characterCreator, #characterEditor, #exitGameMenu, #deleteCharacterMenu").hide();
            return;
        }
        $("#spawnLocation").fadeOut("slow");
    }

    window.addEventListener("message", function(event) {
        const item = event.data;
        if (item.type === "ui") {
            if (item.status) {
                $("#serverName").text(item.serverName);
                $("body").css("background-image", "url(" + item.background + ")");
                display(true);
            } else {
                display(false);
            }
        }
        
        $("#playerAmount").text(item.characterAmount);

        if (item.type === "setSpawns") {
            $("#spawnMenuContainer").empty();
            setTimeout(function(){
                $("#tpDoNot").data("id", item.id);
                JSON.parse(item.spawns).forEach((location) => {
                    $("#spawnMenuContainer").append(`<button class="spawnButtons" data-x="${location.x}" data-y="${location.y}" data-z="${location.z}">${location.name}</button>`);
                });
                $(".spawnButtons").click(function() {
                    $.post(`https://${GetParentResourceName()}/tpToLocation`, JSON.stringify({
                        x: $(this).data("x"),
                        y: $(this).data("y"),
                        z: $(this).data("z")
                    }));
                    spawnMenu(false);
                    setTimeout(function(){
                        $("#spawnMenuContainer").empty();
                    }, 550);
                    return;
                });
                $("#tpDoNot").click(function() {
                    $.post(`https://${GetParentResourceName()}/tpDoNot`, JSON.stringify({
                        id: $("#tpDoNot").data("id")
                    }));
                    spawnMenu(false)
                    setTimeout(function(){
                        $("#spawnMenuContainer").empty();
                    }, 550);
                    return;
                });
            }, 10);
        }

        if (item.type === "firstSpawn") {
            $("#tpDoNot").text("Do not teleport")
        }

        if (item.type === "givePerms") {
            JSON.parse(item.deptRoles).forEach((dept) => {
                $(".departments").append($("<option>", {
                    text: dept
                }));
            });
        }

        if (item.type === "aop") {
            $("#aop").text(`AOP: ${item.aop}`);
        }

        if (item.type === "refresh") {
            $("#charactersSection").empty();
            characterCreatorMenu(false);
            let characters = JSON.parse(item.characters)
            Object.keys(characters).forEach((id) => {
                createCharacter(characters[id].firstName, characters[id].lastName, characters[id].dob, characters[id].gender, characters[id].twt, characters[id].job, characters[id].cash, characters[id].bank, characters[id].id);
            });
        }
    })

    function createCharacter(firstName, lastName, dateOfBirth, gender, twtName, department, startingCash, startingBank, id) {
        if ((firstName.length + lastName.length + department.length) > 24) {
            $("#charactersSection").append(`<button id="characterButton${id}" class="createdButton animated"><span>${firstName} ${lastName} (${department})</span></button><button id="characterButtonEdit${id}" class="createdButtonEdit"><a class="fas fa-edit"></a> Edit</button><button id="characterButtonDelete${id}" class="createdButtonDelete"><a class="fas fa-trash-alt"></a> Delete</button>`);
        } else {
            $("#charactersSection").append(`<button id="characterButton${id}" class="createdButton"><span>${firstName} ${lastName} (${department})</span></button><button id="characterButtonEdit${id}" class="createdButtonEdit"><a class="fas fa-edit"></a> Edit</button><button id="characterButtonDelete${id}" class="createdButtonDelete"><a class="fas fa-trash-alt"></a> Delete</button>`);
        }
        $(`#characterButton${id}`).click(function() {
            spawnMenu(true)
            $.post(`https://${GetParentResourceName()}/setMainCharacter`, JSON.stringify({
                id: id
            }));
            return;
        });
        $(`#characterButtonEdit${id}`).click(function() {
            characterEditorMenu(true)
            $("#newFirstName").val(firstName);
            $("#newLastName").val(lastName);
            $("#newDateOfBirth").val(dateOfBirth);
            $("#newGender").val(gender);
            $("#newTwtName").val(twtName);
            $("#newDepartment").val(department);
            characterEdited = id
            return;
        });
        $(`#characterButtonDelete${id}`).click(function() {
            confirmDeleteMenu(true)
            characterDeleting = id
            return;
        });
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
        return false;
    });

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
        return false;
    });

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
        return;
    });

    $("#newCharacterButton").click(function() {
        characterCreatorMenu(true)
        return;
    });

    $("#deleteCharacterCancel").click(function() {
        confirmDeleteMenu(false)
        return;
    });
    $("#cancelCharacterCreation").click(function() {
        characterCreatorMenu(false)
        return;
    });
    $("#cancelCharacterEditing").click(function() {
        characterEditorMenu(false)
        return;
    });

    $("#tpCancel").click(function() {
        spawnMenu(false)
        setTimeout(function(){
            $("#spawnMenuContainer").empty();
        }, 550);
        return;
    });

    $("#quitGameButton").click(function() {
        exitGameMenu(true)
        return;
    });
    $("#exitGameCancel").click(function() {
        exitGameMenu(false)
        return;
    });
    $("#exitGameConfirm").click(function() {
        $.post(`https://${GetParentResourceName()}/exitGame`);
        return;
    });
});
