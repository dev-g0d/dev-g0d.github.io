// ==UserScript==
// @name        Steam-Devg0d
// @namespace   DEVg0d
// @version     3.0
// @description dev.g0d.cfg with integrated Steam App Info Simplifier popup
// @author      DEVg0d
// @match       *://store.steampowered.com/app/*
// @match       *://store.steampowered.com/app/*/
// @grant       GM_addStyle
// @grant       GM_xmlhttpRequest
// @run-at      document-idle
// @updateURL       https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/g0dscript.user.js
// @downloadURL     https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/g0dscript.user.js
// @connect     raw.githubusercontent.com
// ==/UserScript==

(function() {
    'use strict';

    console.log('TM Script 2.14: Steam Custom Button - Initializing...');

    const JSON_DATA_URL = 'https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/steam_app.json';
    let gameData = null;

    GM_addStyle(`
        #myCustomButtonArea {
            position: relative !important;
            display: inline-block !important;
            margin-right: 8px !important;
            vertical-align: top !important;
        }

        #myCustomButtonDropdown .queue_menu_flyout {
            position: absolute !important;
            top: 100% !important;
            left: 0 !important;
            margin-top: -5px !important;
            z-index: 1000 !important;
            background-color: #25282e !important;
            border: 1px solid #1a3146 !important;
            padding: 0 !important; /* กำหนด padding ให้กับ option แทน */
            min-width: 250px !important;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.5) !important;
        }

        #myCustomButtonDropdown .queue_menu_option {
            padding: 8px 10px !important; /* เพิ่ม padding ทั้งแนวตั้งและแนวนอน */
            cursor: pointer !important;
            display: flex !important;
            align-items: center !important;
            border: none !important;
            background: none !important;
            width: 100% !important; /* สำคัญ: กำหนดให้กว้างเต็ม parent */
            box-sizing: border-box !important; /* รวม padding ใน width */
            text-align: left !important;
            color: #66c0f4 !important;
        }
        #myCustomButtonDropdown .queue_menu_option:hover {
            background-color: #3b404a !important; /* สี Hover ที่ Steam มักใช้ */
        }
        #myCustomButtonDropdown .queue_menu_option_label {
            flex-grow: 1 !important;
        }
        #myCustomButtonDropdown .option_title {
            font-weight: bold !important;
            color: #ffffff !important;
        }
        #myCustomButtonDropdown .option_subtitle {
            font-size: 1em !important;
            color: #8f98a0 !important;
        }
        #myCustomButtonDropdown .queue_ignore_menu_option_image {
            margin-right: 8px !important;
            min-width: 16px;
            min-height: 16px;
        }
    `);

    function getAppIdFromUrl() {
        const match = window.location.pathname.match(/\/app\/(\d+)\//);
        if (match && match[1]) {
            return match[1];
        }
        return null;
    }

    function fetchJsonData() {
        return new Promise((resolve, reject) => {
            console.log('TM Script 2.14: Fetching JSON data from:', JSON_DATA_URL);
            GM_xmlhttpRequest({
                method: "GET",
                url: JSON_DATA_URL,
                onload: function(response) {
                    if (response.status === 200) {
                        try {
                            const allData = JSON.parse(response.responseText);
                            const currentAppIdStr = getAppIdFromUrl();
                            const currentAppIdNum = parseInt(currentAppIdStr);

                            if (Array.isArray(allData)) {
                                gameData = allData.find(item => item.app === currentAppIdStr || item.app === currentAppIdNum);
                            } else if (typeof allData === 'object' && allData !== null) {
                                gameData = allData[currentAppIdStr] || allData[currentAppIdNum];
                            } else {
                                console.warn('TM Script 2.14: JSON data is neither an array nor an object:', allData);
                                gameData = null;
                                resolve(null);
                            }

                            console.log('TM Script 2.14: JSON data fetched and processed for app:', currentAppIdStr, gameData);
                            resolve(gameData);
                        } catch (e) {
                            console.error('TM Script 2.14: Error parsing JSON or processing data:', e);
                            gameData = null;
                            resolve(null);
                        }
                    } else {
                        console.error('TM Script 2.14: Failed to fetch JSON data. Status:', response.status);
                        gameData = null;
                        resolve(null);
                    }
                },
                onerror: function(error) {
                    console.error('TM Script 2.14: Network error fetching JSON:', error);
                    gameData = null;
                    resolve(null);
                }
            });
        });
    }

    function createCustomButtonAndDropdown(gameData) {
        const optionDataMap = {
            'custom_option_download': { label: 'ดาวน์โหลด', linkKey: 'download', infoKey: 'download_info' },
            'custom_option_fix': { label: 'แก้ไข', linkKey: 'fix', infoKey: 'fix_info' },
            'custom_option_mf_lua': { label: 'Lua & Manifest', linkKey: 'MF_LUA', infoKey: 'MF_LUA_info' }
        };

        let dropdownOptionsHtml = '';
        let hasAnyValidLink = false;

        for (const optionId in optionDataMap) {
            const optionInfo = optionDataMap[optionId];
            const linkValue = gameData ? gameData[optionInfo.linkKey] : null;

            if (linkValue && typeof linkValue === 'string' && linkValue.trim() !== '') {
                hasAnyValidLink = true;
                const subtitleText = gameData[optionInfo.infoKey] || 'คลิกเพื่อดำเนินการ';

                dropdownOptionsHtml += `
                    <button class="queue_menu_option" role="menuitem" id="${optionId}">
                        <div>
                            <img class="queue_ignore_menu_option_image selected" src="https://store.fastly.steamstatic.com/public/images/v6/ico/ico_selected_bright.png" style="display:none;">
                            <img class="queue_ignore_menu_option_image unselected" src="https://store.fastly.steamstatic.com/public/images/v6/ico/ico_unselected_bright.png">
                        </div>
                        <div class="queue_menu_option_label">
                            <div class="option_title">${optionInfo.label}</div>
                            <div class="option_subtitle">${subtitleText}</div>
                        </div>
                    </button>
                `;
            }
        }

        if (!hasAnyValidLink) {
            console.log('TM Script 2.14: No valid links found for this App ID. Not creating button.');
            return null;
        }

        const customButtonHtml = `
            <div id="myCustomButtonArea" class="btn_active_tooltip">
                <div class="queue_control_button queue_btn_ignore">
                    <button class="btnv6_blue_hoverfade btn_medium queue_btn_inactive"
                            data-panel="{&quot;focusable&quot;:true,&quot;clickOnActivate&quot;:true}"
                            role="button" data-tooltip-text="เครื่องมือสำหรับ DEV/g0d">
                        <span>DEV/g0d</span>
                    </button>
                    <button class="btnv6_blue_hoverfade btn_medium queue_btn_active"
                            data-panel="{&quot;focusable&quot;:true,&quot;clickOnActivate&quot;:true}"
                            role="button" style="display: none;">
                        <span><img src="https://store.fastly.steamstatic.com/public/images/v6/ico/ico_selected.png" border="0"> DEV/g0d (Active)</span>
                    </button>
                </div>
                <div id="myCustomButtonDropdown" class="queue_control_button queue_btn_menu">
                    <button class="queue_menu_arrow btn_medium" id="my_custom_menu_arrow" aria-haspopup="menu" aria-expanded="false" aria-controls="my_custom_menu_flyout">
                        <span><img alt="ตัวเลือกเพิ่มเติม" src="https://store.fastly.steamstatic.com/public/images/v6/btn_arrow_down_padded.png"></span>
                    </button>
                    <div class="queue_menu_flyout" id="my_custom_menu_flyout" role="menu">
                        <div class="queue_menu_flyout_content">
                            ${dropdownOptionsHtml}
                        </div>
                    </div>
                </div>
            </div>
        `;
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = customButtonHtml.trim();
        return tempDiv.firstChild;
    }

    function setupInteractions(customButtonElement, data) {
        gameData = data;

        const buttonArea = customButtonElement;
        const mainButton = buttonArea.querySelector('.queue_btn_ignore .queue_btn_inactive');
        const arrowButton = buttonArea.querySelector('#my_custom_menu_arrow');
        const dropdownMenu = buttonArea.querySelector('#my_custom_menu_flyout');
        const dropdownContent = dropdownMenu.querySelector('.queue_menu_flyout_content');

        if (!buttonArea || !mainButton || !arrowButton || !dropdownMenu || !dropdownContent) {
            console.error('TM Script 2.14: Missing elements for custom button setup. Check HTML structure.');
            return;
        }

        let dropdownTimeout;
        let isHoveringButtonArea = false;
        let isHoveringDropdownMenu = false;

        function showDropdown() {
            clearTimeout(dropdownTimeout);
            dropdownMenu.style.display = 'block';
            arrowButton.classList.add('queue_btn_active');
        }

        function hideDropdown() {
            if (!isHoveringButtonArea && !isHoveringDropdownMenu) {
                dropdownTimeout = setTimeout(() => {
                    dropdownMenu.style.display = 'none';
                    arrowButton.classList.remove('queue_btn_active');
                }, 200);
            }
        }

        buttonArea.addEventListener('mouseenter', () => {
            isHoveringButtonArea = true;
            showDropdown();
        });
        buttonArea.addEventListener('mouseleave', () => {
            isHoveringButtonArea = false;
            hideDropdown();
        });

        dropdownMenu.addEventListener('mouseenter', () => {
            isHoveringDropdownMenu = true;
            showDropdown();
        });
        dropdownMenu.addEventListener('mouseleave', () => {
            isHoveringDropdownMenu = false;
            hideDropdown();
        });

        document.addEventListener('click', (event) => {
            if (!buttonArea.contains(event.target) && !dropdownMenu.contains(event.target)) {
                hideDropdown();
            }
        });

        const optionDataMap = {
            'custom_option_download': { linkKey: 'download' },
            'custom_option_fix': { linkKey: 'fix' },
            'custom_option_mf_lua': { linkKey: 'MF_LUA' }
        };

        dropdownMenu.querySelectorAll('.queue_menu_option').forEach(optionButton => {
            const optionId = optionButton.id;
            const optionInfo = optionDataMap[optionId];
            const linkValue = gameData[optionInfo.linkKey];

            optionButton.dataset.clicked = "false";
            const selectedImg = optionButton.querySelector('.selected');
            const unselectedImg = optionButton.querySelector('.unselected');
            function updateCheckboxVisual() {
                if (optionButton.dataset.clicked === "true") {
                    selectedImg.style.display = 'inline-block';
                    unselectedImg.style.display = 'none';
                } else {
                    selectedImg.style.display = 'none';
                    unselectedImg.style.display = 'inline-block';
                }
            }
            updateCheckboxVisual();

            optionButton.addEventListener('click', function(event) {
                event.preventDefault();
                this.dataset.clicked = "true";
                updateCheckboxVisual();

                console.log(`TM Script 2.14: Clicked option: ${optionId}`);
                window.open(linkValue, '_blank');
            });
        });
        console.log('TM Script 2.14: Dropdown interactions setup.');
    }

    function runScript() {
        const customButtonExists = document.getElementById('myCustomButtonArea');
        if (customButtonExists) {
            console.log('TM Script 2.14: Custom button already exists. Skipping runScript.');
            return true;
        }

        const wishlistButtonContainer = document.querySelector('.queue_control_button .queue_btn_wishlist');
        const followButtonContainer = document.querySelector('.queue_control_button .queue_btn_follow');
        const ignoreButtonContainer = document.querySelector('.queue_control_button.queue_btn_ignore');

        let targetElementToInsertBefore = null;
        let insertionParent = null;

        if (wishlistButtonContainer) {
            targetElementToInsertBefore = wishlistButtonContainer.closest('.queue_control_button');
            insertionParent = targetElementToInsertBefore ? targetElementToInsertBefore.parentNode : null;
            console.log('TM Script 2.14: Found wishlist button container as target.');
        } else if (followButtonContainer) {
            targetElementToInsertBefore = followButtonContainer.closest('.queue_control_button');
            insertionParent = targetElementToInsertBefore ? targetElementToInsertBefore.parentNode : null;
            console.log('TM Script 2.14: Found follow button container as target.');
        } else if (ignoreButtonContainer) {
            targetElementToInsertBefore = ignoreButtonContainer;
            insertionParent = targetElementToInsertBefore ? targetElementToInsertBefore.parentNode : null;
            console.log('TM Script 2.14: Found ignore button container as target.');
        }

        if (!insertionParent) {
            const queueActionsCtn = document.getElementById('queueActionsCtn');
            if (queueActionsCtn) {
                insertionParent = queueActionsCtn.querySelector('.queue_control_buttons');
                if (insertionParent) {
                    console.log('TM Script 2.14: Found .queue_control_buttons as insertion parent.');
                } else {
                    insertionParent = queueActionsCtn;
                    console.log('TM Script 2.14: Falling back to #queueActionsCtn as insertion parent.');
                }
            }
        }

        if (!insertionParent) {
            console.log('TM Script 2.14: No suitable insertion point found yet. Waiting...');
            return false;
        }

        console.log('TM Script 2.14: Found insertion point. Fetching JSON data...');

        fetchJsonData().then(data => {
            const customButton = createCustomButtonAndDropdown(data);

            if (customButton) {
                if (targetElementToInsertBefore && targetElementToInsertBefore.parentNode === insertionParent) {
                    insertionParent.insertBefore(customButton, targetElementToInsertBefore);
                    console.log('TM Script 2.14: Custom button inserted before specific Steam button.');
                } else {
                    insertionParent.prepend(customButton);
                    console.log('TM Script 2.14: Custom button prepended to insertion parent.');
                }
                setupInteractions(customButton, data);
            } else {
                console.log('TM Script 2.14: No custom button created due to insufficient data.');
            }
        });
        return true;
    }

    const observer = new MutationObserver((mutationsList, observer) => {
        if (runScript()) {
            console.log('TM Script 2.14: Stopping MutationObserver. Script process initiated.');
            observer.disconnect();
        }
    });

    observer.observe(document.body, { childList: true, subtree: true });

    setTimeout(() => {
        if (!document.getElementById('myCustomButtonArea')) {
            if (runScript()) {
                console.log('TM Script 2.14: Script process initiated on initial delayed run. Disconnecting observer.');
                observer.disconnect();
            }
        } else {
            console.log('TM Script 2.14: Button already present on delayed run check. No action needed.');
        }
    }, 1500);
})();
