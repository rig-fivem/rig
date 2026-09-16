/*
----------------------------------------
RIG Framework (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

export class TextUI {
    constructor(default_position = "bottom-center") {
        this.current_item = null;
        this.position = default_position;
    }

    resolve_position_style(position) {
        const map = {
            "top-left": "top:10vh;left:2vw;",
            "top-center": "top:10vh;left:50%;transform:translateX(-50%);",
            "top-right": "top:10vh;right:2vw;",
            "left-center": "top:50%;left:2vw;transform:translateY(-50%);",
            "right-center": "top:50%;right:2vw;transform:translateY(-50%);",
            "bottom-left": "bottom:10vh;left:2vw;",
            "bottom-center": "bottom:10vh;left:50%;transform:translateX(-50%);",
            "bottom-right": "bottom:10vh;right:2vw;"
        };
        return map[position] || map["bottom-center"];
    }

    set_data(data) {
        const next_position = data.position || this.position;
        const position_changed = next_position !== this.position;
        this.position = next_position;

        if (!$(".text_ui").length || position_changed) {
            this.destroy();
            this.build(data.image !== undefined);
        }

        this.current_item = data;
        this.update_display();
    }

    build(show_image) {
        const style = this.resolve_position_style(this.position);

        const content = `
            <div class="text_ui" style="${style}">
                ${show_image ? `<div class="text_ui_item"><img id="hint_image" src="" alt="Item Image"></div>` : ""}
                <div class="text_ui_message">
                    <p id="text_ui_status">NO ITEM EQUIPPED</p>
                    <p id="text_ui_action">Press E to Equip Item</p>
                </div>
            </div>
        `;
        $("#ui_focus").append(content);
    }

    update_display() {
        if (!this.current_item) {
            $("#text_ui_status").text("No Item Equipped");
            $("#text_ui_action").text("Press E to equip item");
            if ($("#hint_image").length) $("#hint_image").attr("src", "/ui/assets/images/no_image.png");
            return;
        }

        if (this.current_item.image && $("#hint_image").length) {
            $("#hint_image").attr("src", this.current_item.image);
        }

        if (this.current_item.quantity !== undefined) {
            $("#text_ui_status").html(`<div><span>${this.current_item.label || ""}</span><span id="hint_quantity">${this.current_item.quantity}x</span></div>`);
        } else {
            $("#text_ui_status").text(this.current_item.status_text || this.current_item.label || "");
        }

        $("#text_ui_action").text(this.current_item.action_text || "Press F to interact");
    }

    update_quantity(amount) {
        if (!this.current_item) return;
        this.current_item.quantity = amount;
        $("#hint_quantity").text(amount + "x");
        if (amount === 0) this.clear();
    }

    update_status_text(text) {
        $("#text_ui_status").text(text);
    }

    clear() {
        this.current_item = null;
        this.update_display();
    }

    destroy() {
        $(".text_ui").remove();
    }
}