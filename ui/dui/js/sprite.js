/*
----------------------------------------
RIG Framework (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

export class DUISprite {
    constructor(options) {
        this.keys = options.keys || [];
        this.icon = options.icon || null;
        this.image = options.image || null;
        this.header = options.header || "Header Missing";
        this.progressbars = options.additional?.progressbars || {};
        this.values = options.additional?.values || {};

        this.build();
    }

    build() {
        const key_count = this.keys.length;
        const key_hints = this.keys.map((key_obj, idx) => {
            const is_last_odd = key_count % 2 !== 0 && idx === key_count - 1;
            const is_full_row = key_count === 1 || is_last_odd;
            return `
                <div class="dui_sprite_keys${is_full_row ? " full_row" : ""}">
                    <span class="dui_sprite_key"><p>${key_obj.key}</p></span> 
                    <span class="dui_sprite_key_label">${key_obj.label}</span>
                </div>`;
        }).join("");


        const skill_keys = Object.keys(this.progressbars);
        let progressbars_html = "";

        if (skill_keys.length > 0) {
            progressbars_html = `<div class="dui_sprite_progress_containers">`;

            skill_keys.forEach((key, idx) => {
                const bar = this.progressbars[key];
                const is_last_odd = skill_keys.length % 2 !== 0 && idx === skill_keys.length - 1;
                const is_full_row = skill_keys.length === 1 || is_last_odd;

                progressbars_html += `
                    <div class="dui_sprite_progress_item${is_full_row ? " full_row" : ""}">
                        <h3>${bar.label}</h3>
                        <div class="dui_sprite_progress_bar">
                            <div class="dui_sprite_progress_bar_fill" style="width: ${bar.value}%;"><div class="dui_sprite_progress_header">${bar.value}%</div></div>
                        </div>
                    </div>`;
            });

            progressbars_html += `</div>`;
        }


        const values_section = Object.keys(this.values).length > 0
            ? `<ul class="dui_sprite_values_list">
                ${Object.entries(this.values).map(([key, value]) => `
                    <li><strong>${value.label}:</strong> ${value.value}</li>
                `).join("")}
            </ul>`
            : "";

        const content = `
            <div class="dui_sprite">
                <div class="dui_sprite_header">
                    ${this.icon ? `<i class="${this.icon}"></i>` : this.image ? `<img class="dui_sprite_image" src="${this.image}" alt="icon image" />` : ""}
                    ${this.header ? `<div class="dui_sprite_header_text">${this.header}</div>` : ""}
                </div>
                ${progressbars_html}
                ${values_section}
                <div class="dui_sprite_keys_container">
                    ${key_hints}
                </div>
            </div>`;

        $("#dui_sprite_container").html(content);
    }

    close() {
        $("#dui_sprite_container").empty();
    }
}

/*
const test_dui = new DUISprite({
    header: "Some Test Dui",
    image: "/ui/assets/images/RIG256.png",
    keys: [
        { key: "E", label: "Interact" },
        { key: "F", label: "Alternate" }
    ],
    additional: {
        progressbars: {
            strength: { label: "Strength", value: 75 },
            agility: { label: "Agility", value: 50 },
            health: { label: "Health", value: 50 }
        },
        values: {
            rank: { label: "Rank", value: "Sergeant" }
        }
    }
});
*/