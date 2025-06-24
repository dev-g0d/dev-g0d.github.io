// ==UserScript==
// @name          SteamG0d by DEVg0d
// @namespace     g0d
// @version       1.7
// @description   dev.g0d.cfg with integrated Steam App Info Simplifier popup
// @author        g0d
// @match         https://store.steampowered.com/app/*
// @grant         GM_xmlhttpRequest
// @updateURL       https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/g0dscript.user.js
// @downloadURL     https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/g0dscript.user.js
// @connect       steamui.com

// ==/UserScript==

(function() {
    'use strict';

    let appData = {};

async function fetchAppData() {
    const timestamp = new Date().getTime();
    const originalJsonUrl = `https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/refs/heads/main-site/site/excute/steam_app.json?t=${timestamp}`;

    const proxyJsonUrl = `https://thingproxy.freeboard.io/fetch/${encodeURIComponent(originalJsonUrl)}`;

    return new Promise(async (resolve, reject) => {
        try {
            await new Promise((innerResolve, innerReject) => {
                GM_xmlhttpRequest({
                    method: "GET",
                    url: proxyJsonUrl,
                    onload: function(response) {
                        if (response.status === 200) {
                            try {
                                appData = JSON.parse(response.responseText);
                                console.log('ข้อมูลเกมถูกดึงโดยใช้ proxy สำเร็จ!');
                                innerResolve();
                            } catch (e) {
                                console.error('เกิดข้อผิดพลาดในการแยกวิเคราะห์ JSON (จาก proxy):', e);
                                innerReject(new Error('JSON parse error from proxy'));
                            }
                        } else {
                            console.warn(`ล้มเหลวในการดึงข้อมูลจาก proxy (สถานะ: ${response.status}). กำลังลองดึงตรง...`);
                            innerReject(new Error(`Proxy request failed with status: ${response.status}`));
                        }
                    },
                    onerror: function(error) {
                        console.error('เกิดข้อผิดพลาดเครือข่ายเมื่อดึงข้อมูลจาก proxy:', error);
                        innerReject(new Error('Network error from proxy'));
                    }
                });
            });
            resolve();
        } catch (error) {
            console.warn('Proxy ไม่สามารถใช้งานได้ หรือมีปัญหา, กำลังลองดึงข้อมูลตรงจาก GitHub...');
            GM_xmlhttpRequest({
                method: "GET",
                url: originalJsonUrl,
                onload: function(response) {
                    if (response.status === 200) {
                        try {
                            appData = JSON.parse(response.responseText);
                            console.log('ข้อมูลเกมถูกดึงโดยตรงจาก GitHub สำเร็จ!');
                            resolve();
                        } catch (e) {
                            console.error('เกิดข้อผิดพลาดในการแยกวิเคราะห์ JSON (จาก GitHub):', e);
                            reject(new Error('JSON parse error from GitHub'));
                        }
                    } else {
                        console.error(`ไม่สามารถเชื่อมต่อเพื่อดึงข้อมูลเกมได้ (ถูกบล็อก). อาจมีปัญหาเครือข่ายหรือนโยบายความปลอดภัย. กรุณาลองใหม่ภายหลัง (สถานะ: ${response.status})`);
                        reject(new Error(`Failed to fetch data directly from GitHub with status: ${response.status}`));
                    }
                },
                onerror: function(error) {
                    console.error('ไม่สามารถเชื่อมต่อเพื่อดึงข้อมูลเกมได้ (ถูกบล็อก). อาจมีปัญหาเครือข่ายหรือนโยบายความปลอดภัย. กรุณาลองใหม่ภายหลัง (ข้อผิดพลาดเครือข่าย):', error);
                    reject(new Error('Network error when fetching directly from GitHub'));
                }
            });
        }
    });
}

    async function checkUrlStatus(url) {
        return new Promise(resolve => {
            if (!url || url === '#' || url.startsWith('javascript:')) {
                console.log(`Skipping status check for invalid URL: ${url}`);
                return resolve(false);
            }
            GM_xmlhttpRequest({
                method: "HEAD",
                url: url,
                onload: function(response) {
                    if (response.status >= 200 && response.status < 300) {
                        console.log(`URL ${url} is accessible (Status: ${response.status})`);
                        resolve(true);
                    } else {
                        console.log(`URL ${url} returned status: ${response.status} ${response.statusText}`);
                        resolve(false);
                    }
                },
                onerror: function(error) {
                    console.error(`Error checking URL status for ${url}:`, error);
                    resolve(false);
                },
                ontimeout: function() {
                    console.warn(`Timeout checking URL status for ${url}`);
                    resolve(false);
                }
            });
        });
    }

    function injectCss(cssString) {
        const style = document.createElement('style');
        style.textContent = cssString;
        document.head.appendChild(style);
    }

    const customCss = `
        .sd_overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10000;
        }

        .sd_popup_content {
            background: linear-gradient(to bottom, #1a232f 0%, #111111 100%);
            background-color: #1a232f;
            border-radius: 4px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.8);
            max-width: 550px;
            width: 90%;
            color: #dcdcdc;
            font-family: "Motiva Sans", Sans-serif, Arial, Helvetica;
            text-align: center;
            position: relative;
            display: flex;
            flex-direction: column;
            box-sizing: border-box;
            padding: 20px;
        }

        .sd_popup_content h2 {
            color: #ffffff;
            margin-top: 0;
            margin-bottom: 10px;
            font-size: 1.6em;
            font-weight: bold;
        }

        .sd_popup_content .sd_popup_message {
            color: #b0b0b0;
            margin-bottom: 20px;
            font-size: 0.95em;
        }

        .sd_popup_content .sd_popup_buttons {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 20px;
        }

        .sd_popup_content .sd_popup_button {
            background: linear-gradient(to bottom, #4c96e6 5%, #2a6dbf 100%);
            background-color: #4c96e6;
            color: #ffffff;
            border: 1px solid #1a5180;
            padding: 12px 25px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 1.1em;
            font-weight: bold;
            text-decoration: none;
            transition: background-color 0.2s ease, background 0.2s ease, border-color 0.2s ease;
            white-space: nowrap;
            flex-grow: 1;
            flex-basis: 0;
            min-width: 140px;
            box-sizing: border-box;
            box-shadow: 0 1px 0 rgba(255, 255, 255, 0.1) inset, 0 1px 2px rgba(0, 0, 0, 0.5);
        }

        .sd_popup_content .sd_popup_button:hover {
            background: linear-gradient(to bottom, #5dacef 5%, #3e84d4 100%);
            background-color: #5dacef;
            border-color: #2b70b6;
        }

        .sd_popup_close_button {
            position: absolute;
            top: 10px;
            right: 10px;
            background: none;
            border: none;
            color: #888888;
            font-size: 1.8em;
            cursor: pointer;
            line-height: 1;
            padding: 0 5px;
            transition: color 0.2s ease;
        }
        .sd_popup_close_button:hover {
            color: #ffffff;
        }

        .sd_game_info_container {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .sd_game_info_container img {
            width: 150px;
            height: 80px;
            border-radius: 4px;
            margin-right: 15px;
            object-fit: cover;
        }

        .sd_game_info_container .sd_game_name_text {
            font-size: 1.3em;
            font-weight: bold;
            color: #ffffff;
            text-align: left;
            flex-grow: 1;
        }
        .sd_download_button_style {
            background: linear-gradient(to bottom, #4c96e6 5%, #2a6dbf 100%);
            background-color: #4c96e6;
            color: #fff;
            padding: 10px 20px;
            border: 1px solid #1a5180;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.2s ease, background 0.2s ease, border-color 0.2s ease;
            box-shadow: 0 1px 0 rgba(255, 255, 255, 0.1) inset, 0 1px 2px rgba(0, 0, 0, 0.5);
        }
        .sd_download_button_style:hover {
            background: linear-gradient(to bottom, #5dacef 5%, #3e84d4 100%);
            background-color: #5dacef;
            border-color: #2b70b6;
        }

        .sd_fix_button_style {
            background: linear-gradient(to bottom, #4c96e6 5%, #2a6dbf 100%);
            background-color: #4c96e6;
            color: #fff;
            padding: 10px 20px;
            border: 1px solid #1a5180;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.2s ease, background 0.2s ease, border-color 0.2s ease;
            box-shadow: 0 1px 0 rgba(255, 255, 255, 0.1) inset, 0 1px 2px rgba(0, 0, 0, 0.5);
        }
        .sd_fix_button_style:hover {
            background: linear-gradient(to bottom, #5dacef 5%, #3e84d4 100%);
            background-color: #5dacef;
            border-color: #2b70b6;
        }

        .sd_how_to_use_link {
            text-align: center;
            padding: 5px;
            cursor: pointer;
            color: #76aaff;
            font-size: 1.0em;
            margin-top: 15px;
            text-decoration: underline;
            transition: color 0.2s ease;
        }
        .sd_how_to_use_link:hover {
            color: #a0caff;
        }
        .sd_password_info {
            color: #dcdcdc;
            font-size: 1.1em;
            margin-top: 5px;
        }
    `;

    injectCss(customCss);

    function showMessageBox(titleText, messageHtml) {
        const overlay = document.createElement('div');
        overlay.className = 'sd_overlay';
        overlay.id = 'sd-message-box-overlay';

        const popupContent = document.createElement('div');
        popupContent.className = 'sd_popup_content';

        const closeButton = document.createElement('button');
        closeButton.className = 'sd_popup_close_button';
        closeButton.textContent = '×';
        closeButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        popupContent.appendChild(closeButton);

        const title = document.createElement('h2');
        title.textContent = titleText;
        popupContent.appendChild(title);

        const message = document.createElement('div');
        message.className = 'sd_popup_message';
        message.innerHTML = messageHtml;
        popupContent.appendChild(message);

        const okButton = document.createElement('button');
        okButton.type = 'button';
        okButton.className = 'sd_popup_button';
        okButton.textContent = 'ตกลง';
        okButton.style.marginTop = '20px';
        okButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        popupContent.appendChild(okButton);

        overlay.appendChild(popupContent);
        document.body.appendChild(overlay);

        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                document.body.removeChild(overlay);
            }
        });
    }

    function createHowToUseDialog(howToText) {
        const overlay = document.createElement('div');
        overlay.className = 'sd_overlay';
        overlay.id = 'sd-how-to-use-popup-overlay';

        const popupContent = document.createElement('div');
        popupContent.className = 'sd_popup_content';

        const closeButton = document.createElement('button');
        closeButton.className = 'sd_popup_close_button';
        closeButton.textContent = '×';
        closeButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        popupContent.appendChild(closeButton);

        const title = document.createElement('h2');
        title.textContent = 'วิธีการใช้งาน / ติดตั้ง';
        popupContent.appendChild(title);

        const message = document.createElement('div');
        message.className = 'sd_popup_message';
        message.style.textAlign = 'left';
        message.innerHTML = howToText;
        popupContent.appendChild(message);

        const okButton = document.createElement('button');
        okButton.type = 'button';
        okButton.className = 'sd_popup_button';
        okButton.textContent = 'ปิด';
        okButton.style.marginTop = '20px';
        okButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        popupContent.appendChild(okButton);

        overlay.appendChild(popupContent);
        document.body.appendChild(overlay);

        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                document.body.removeChild(overlay);
            }
        });
    }

    function createDownloadSuccessDialog() {
        const gameHeaderImageElement = document.querySelector('.game_header_image_full');
        const gameImageUrl = gameHeaderImageElement ? gameHeaderImageElement.src : 'https://placehold.co/150x80/000000/FFFFFF?text=Image+Not+Found';
        const gameName = document.querySelector('.apphub_AppName')?.textContent || 'Game Name Not Found';
        const appId = window.location.pathname.split('/')[2] || '';

        const currentAppData = appData[`app:${appId}`] || {};

        const gdownloadUrl = currentAppData.gdownload || '#';
        const fdownloadUrl = currentAppData.fdownload || '#';
        const gpasswordDisplay = currentAppData.gpassword ? `รหัสผ่าน: ${currentAppData.gpassword}` : '';
        const fpasswordDisplay = currentAppData.fpassword ? `รหัสผ่านแก้ไข: ${currentAppData.fpassword}` : '';
        const howToRaw = currentAppData.how || '';
        const byInfo = currentAppData.by || '';

        const overlay = document.createElement('div');
        overlay.className = 'sd_overlay';

        const dialogContainer = document.createElement('div');
        dialogContainer.className = 'sd_popup_content';
        dialogContainer.innerHTML = `
            <div class="bCGAC51za6R_thjPd7_vw" style="font-size: 20px; font-weight: bold; margin-bottom: 15px; text-align: center;">ข้อมูลการใช้งาน</div>
            <div class="Panel Focusable">
                <div class="XjPmFc2t_i1DAuEXEbIX Panel Focusable">
                    <div class="sd_game_info_container">
                        <div class="_2Xz_WXO8PfREP4c9ZWAuNg">
                            <img src="${gameImageUrl}" alt="Game Header Image" onerror="this.onerror=null;this.src='https://placehold.co/150x80/000000/FFFFFF?text=Image+Not+Found';">
                        </div>
                        <div class="_3GKl4T2MbvnGPvRzyXC5nQ" style="text-align: left; flex-grow: 1;">
                            <div class="sd_game_name_text">${gameName}</div>
                            ${byInfo ? `<div style="font-size: 1.0em; color: #dcdcdc; margin-top: 5px;">โดย: ${byInfo}</div>` : ''}
                            ${gpasswordDisplay ? `<div class="sd_password_info" style="text-align: left; ${byInfo ? '' : 'margin-top: 10px;'}">${gpasswordDisplay}</div>` : ''}
                            ${fpasswordDisplay ? `<div class="sd_password_info" style="text-align: left;">${fpasswordDisplay}</div>` : ''}
                        </div>
                    </div>
                </div>
            </div>
            <div style="clear: both; margin-top: 20px; display: flex; justify-content: center; gap: 10px; flex-wrap: wrap;">
                <a href="${gdownloadUrl}" target="_blank" class="sd_download_button_style" id="gdownload-btn">ดาวน์โหลด</a>
                <a href="${fdownloadUrl}" target="_blank" class="sd_fix_button_style" id="fdownload-btn">แก้ไข</a>
            </div>
            ${howToRaw ? `<div class="sd_how_to_use_link">วิธีใช้งาน/ติดตั้ง</div>` : ''}
        `;

        const closeButton = document.createElement('button');
        closeButton.className = 'sd_popup_close_button';
        closeButton.textContent = '×';
        closeButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        dialogContainer.prepend(closeButton);

        overlay.appendChild(dialogContainer);
        document.body.appendChild(overlay);

        overlay.addEventListener('click', (event) => {
            if (event.target === overlay) {
                document.body.removeChild(overlay);
            }
        });

        const howToUseLink = dialogContainer.querySelector('.sd_how_to_use_link');
        if (howToUseLink) {
            howToUseLink.addEventListener('click', () => {
                document.body.removeChild(overlay);
                const howToTextFormatted = howToRaw.replace(/;/g, '<br>');
                createHowToUseDialog(howToTextFormatted);
            });
        }
    }

    // Function to handle the Steam App Info summary popup
    function createAppInfoSummaryDialog(appId) {
        const apiUrl = `https://steamui.com/api/get_appinfo.php?appid=${appId}`;

        // Show a loading message while fetching data
        showMessageBox('กำลังโหลดข้อมูล...', 'กรุณารอสักครู่ กำลังดึงข้อมูล Steam App...');

        GM_xmlhttpRequest({
            method: "GET",
            url: apiUrl,
            onload: function(response) {
                // Remove loading message
                const existingOverlay = document.getElementById('sd-message-box-overlay');
                if (existingOverlay) {
                    document.body.removeChild(existingOverlay);
                }

                try {
                    const raw = response.responseText;
                    const data = parseVDF(raw);

                    const appInfo = data?.appinfo;
                    const extractedAppId = appInfo?.appid;
                    const name = appInfo?.common?.name;
                    const baseGameDepotId = parseInt(extractedAppId) + 1; // Assuming depot ID is appid + 1
                    const baseGameManifestGid = appInfo?.depots?.[`${baseGameDepotId}`]?.manifests?.public?.gid;

                    const dlcListString = appInfo?.extended?.listofdlc;
                    const dlcAppIds = dlcListString ? dlcListString.split(',') : [];
                    const dlcManifests = [];

                    for (const dlcAppId of dlcAppIds) {
                        const dlcManifestGid = appInfo?.depots?.[dlcAppId]?.manifests?.public?.gid;
                        if (dlcManifestGid) {
                            dlcManifests.push({
                                dlcAppId: dlcAppId,
                                manifestGid: dlcManifestGid
                            });
                        }
                    }

                    // Construct the HTML for the summary popup
                    let popupHtml = `
                        <div style="font-family: 'Inter', sans-serif; background-color: #1a202c; color: #e2e8f0; padding: 20px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4); border: 1px solid #4a5568;">
                            <h2 style="color: #63b3ed; margin-top: 0; margin-bottom: 15px; font-size: 1.5rem; border-bottom: 1px solid #4a5568; padding-bottom: 10px; text-align: center;">ข้อมูล Steam App ที่สรุปแล้ว</h2>
                            <ul style="list-style-type: none; padding: 0;">
                                <li style="margin-bottom: 10px; font-size: 1.1rem;"><strong>ID เกม:</strong> ${extractedAppId || 'ไม่พบข้อมูล'}</li>
                                <li style="margin-bottom: 10px; font-size: 1.1rem;"><strong>ชื่อเกม:</strong> ${name || 'ไม่พบข้อมูล'}</li>
                                <li style="margin-bottom: 10px; font-size: 1.1rem;"><strong>Manifest ล่าสุด (เกมหลัก):</strong> ${baseGameDepotId}_${baseGameManifestGid || 'ไม่พบข้อมูล'}.manifest</li>
                            </ul>`;

                    if (dlcManifests.length > 0) {
                        popupHtml += `
                            <h3 style="color: #63b3ed; margin-top: 20px; margin-bottom: 10px; font-size: 1.3rem;">DLC (${dlcManifests.length}):</h3>
                            <ul style="list-style-type: none; padding: 0;">`;
                        for (const dlc of dlcManifests) {
                            popupHtml += `<li style="margin-bottom: 5px; font-size: 1.1rem;">${dlc.dlcAppId}_${dlc.manifestGid}.manifest</li>`;
                        }
                        popupHtml += `</ul>`;
                    } else {
                        popupHtml += `<ul style="list-style-type: none; padding: 0;"><li style="margin-bottom: 10px; font-size: 1.1rem;"><strong>DLC:</strong> ไม่พบข้อมูล DLC</li></ul>`;
                    }

                    popupHtml += `
                            <div style="text-align: right; margin-top: 20px; font-size: 0.9rem; color: #718096;">devg0d</div>
                        </div>
                    `;

                    // Create and display the popup
                    const overlay = document.createElement('div');
                    overlay.className = 'sd_overlay';

                    const popupContent = document.createElement('div');
                    popupContent.className = 'sd_popup_content';
                    popupContent.style.maxWidth = '600px';
                    popupContent.style.width = 'fit-content';
                    popupContent.style.padding = '0';
                    popupContent.style.background = 'none';
                    popupContent.style.boxShadow = 'none';

                    const closeButton = document.createElement('button');
                    closeButton.className = 'sd_popup_close_button';
                    closeButton.textContent = '×';
                    closeButton.addEventListener('click', function() {
                        document.body.removeChild(overlay);
                    });
                    popupContent.appendChild(closeButton);

                    const contentWrapper = document.createElement('div');
                    contentWrapper.innerHTML = popupHtml;
                    popupContent.appendChild(contentWrapper);

                    overlay.appendChild(popupContent);
                    document.body.appendChild(overlay);

                    overlay.addEventListener('click', function(e) {
                        if (e.target === overlay) {
                            document.body.removeChild(overlay);
                        }
                    });

                } catch (e) {
                    console.error('Steam App Info Simplifier: Parsing Error or Data Not Found in popup:', e);
                    showMessageBox('ข้อผิดพลาด', 'ไม่สามารถโหลดหรือวิเคราะห์ข้อมูล Steam App ได้ กรุณาลองอีกครั้ง.');
                }
            },
            onerror: function(error) {
                // Remove loading message
                const existingOverlay = document.getElementById('sd-message-box-overlay');
                if (existingOverlay) {
                    document.body.removeChild(existingOverlay);
                }
                console.error('Failed to load app info via GM_xmlhttpRequest for popup:', error);
                showMessageBox('ข้อผิดพลาดการเชื่อมต่อ', 'ไม่สามารถดึงข้อมูล Steam App ได้. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตหรือลองใหม่ภายหลัง.');
            }
        });
    }

    function createAddToLibraryDialog() {
        const gameHeaderImageElement = document.querySelector('.game_header_image_full');
        const gameImageUrl = gameHeaderImageElement ? gameHeaderImageElement.src : 'https://placehold.co/150x80/000000/FFFFFF?text=Image+Not+Found';
        const gameName = document.querySelector('.apphub_AppName')?.textContent || 'Game Name Not Found';
        const appId = window.location.pathname.split('/')[2] || '';

        const currentAppData = appData[`app:${appId}`] || {};
        const manifestUrl = currentAppData.manifest || '';

        const overlay = document.createElement('div');
        overlay.className = 'sd_overlay';
        overlay.id = 'sd-add-to-library-popup-overlay';

        const popupContent = document.createElement('div');
        popupContent.className = 'sd_popup_content';

        const closeButton = document.createElement('button');
        closeButton.className = 'sd_popup_close_button';
        closeButton.textContent = '×';
        closeButton.addEventListener('click', function() {
            document.body.removeChild(overlay);
        });
        popupContent.appendChild(closeButton);

        const title = document.createElement('h2');
        title.textContent = `เลือกตัวเลือกสำหรับ App ID: ${appId}`;
        popupContent.appendChild(title);

        const gameInfoContainer = document.createElement('div');
        gameInfoContainer.className = 'sd_game_info_container';
        popupContent.appendChild(gameInfoContainer);

        const gameImage = document.createElement('img');
        gameImage.src = gameImageUrl;
        gameImage.alt = 'Game Header Image';
        gameImage.onerror = function() {
            this.onerror = null;
            this.src = 'https://placehold.co/150x80/000000/FFFFFF?text=Image+Not+Found';
        };
        gameInfoContainer.appendChild(gameImage);

        const gameNameText = document.createElement('div');
        gameNameText.className = 'sd_game_name_text';
        gameNameText.textContent = gameName;
        gameInfoContainer.appendChild(gameNameText);

        const mainMessage = document.createElement('p');
        mainMessage.className = 'sd_popup_message';
        mainMessage.innerHTML = `เลือกตัวเลือกใดเลือกหนึ่ง (ยังไม่รองรับทุกเกม)<br><b>หากเกมไหนมีคุณจะสามารถดาวน์โหลดได้</b>`;
        popupContent.appendChild(mainMessage);

        const buttonsContainer = document.createElement('div');
        buttonsContainer.className = 'sd_popup_buttons';
        popupContent.appendChild(buttonsContainer);

        const button1 = document.createElement('button');
        button1.type = 'button';
        button1.className = 'sd_popup_button';
        button1.textContent = 'dev/g0d';
        button1.id = 'devg0d-btn';
        button1.addEventListener('click', async () => {
            document.body.removeChild(overlay);
            if (manifestUrl) {
                const isAvailable = await checkUrlStatus(manifestUrl);
                if (isAvailable) {
                    window.open(manifestUrl, '_blank');
                } else {
                    showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ Manifest สำหรับ App ID: ${appId}`);
                }
            } else {
                showMessageBox('ไม่พบข้อมูล', `ไม่พบไฟล์ Manifest สำหรับ App ID: ${appId}`);
            }
        });
        buttonsContainer.appendChild(button1);

        const button2 = document.createElement('button');
        button2.type = 'button';
        button2.className = 'sd_popup_button';
        button2.textContent = 'furcate.eu';
        button2.id = 'furcate-btn';
        button2.addEventListener('click', async () => {
            document.body.removeChild(overlay);
            if (appId) {
                const downloadUrl = `https://furcate.eu/FILES/${appId}.zip`;
                const isAvailable = await checkUrlStatus(downloadUrl);
                if (isAvailable) {
                    window.open(downloadUrl, '_blank');
                } else {
                    showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ .zip สำหรับ App ID: ${appId} ที่ furcate.eu`);
                }
            } else {
                showMessageBox('ไม่พบ App ID', `ไม่พบ App ID สำหรับดาวน์โหลดจาก furcate.eu`);
            }
        });
        buttonsContainer.appendChild(button2);

        const button3 = document.createElement('button');
        button3.type = 'button';
        button3.className = 'sd_popup_button';
        button3.textContent = 'fares.top';
        button3.id = 'fares-btn';
        button3.addEventListener('click', async () => {
            document.body.removeChild(overlay);
            if (appId) {
                const downloadUrl = `https://steamdatabase.s3.eu-north-1.amazonaws.com/${appId}.zip`;
                const isAvailable = await checkUrlStatus(downloadUrl);
                if (isAvailable) {
                    window.open(downloadUrl, '_blank');
                } else {
                    showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ .zip สำหรับ App ID: ${appId} ที่ fares.top`);
                }
            } else {
                showMessageBox('ไม่พบ App ID', `ไม่พบ App ID สำหรับดาวน์โหลดจาก fares.top`);
            }
        });
        buttonsContainer.appendChild(button3);

        // Add the new Steam App Info button here
        const steamAppInfoButton = document.createElement('button');
        steamAppInfoButton.type = 'button';
        steamAppInfoButton.className = 'sd_popup_button'; // Reuse existing button style
        steamAppInfoButton.textContent = 'ข้อมูล Steam App ที่สรุปแล้ว';
        steamAppInfoButton.addEventListener('click', () => {
            // Call the new popup function instead of opening a new tab
            document.body.removeChild(overlay); // Close the current popup
            createAppInfoSummaryDialog(appId); // Open the Steam App Info summary popup
        });
        buttonsContainer.appendChild(steamAppInfoButton);


        overlay.appendChild(popupContent);
        document.body.appendChild(overlay);

        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                document.body.removeChild(overlay);
            }
        });

        if (manifestUrl) {
            checkUrlStatus(manifestUrl).then(isAvailable => {
                if (!isAvailable) {
                    button1.textContent = 'dev/g0d (ไม่พบ)';
                    button1.style.backgroundColor = '#555';
                    button1.style.borderColor = '#333';
                    button1.style.cursor = 'not-allowed';
                    button1.onclick = () => showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ Manifest สำหรับ App ID: ${appId}`);
                }
            });
        } else {
            button1.textContent = 'dev/g0d (ไม่พบ)';
            button1.style.backgroundColor = '#555';
            button1.style.borderColor = '#333';
            button1.style.cursor = 'not-allowed';
            button1.onclick = () => showMessageBox('ไม่มีข้อมูล', `ไม่มีข้อมูล Manifest สำหรับ App ID: ${appId}`);
        }

        if (appId) {
            const furcateUrl = `https://furcate.eu/FILES/${appId}.zip`;
            checkUrlStatus(furcateUrl).then(isAvailable => {
                if (!isAvailable) {
                    button2.textContent = 'furcate.eu (ไม่พบ)';
                    button2.style.backgroundColor = '#555';
                    button2.style.borderColor = '#333';
                    button2.style.cursor = 'not-allowed';
                    button2.onclick = () => showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ .zip สำหรับ App ID: ${appId} ที่ furcate.eu`);
                }
            });

            const faresUrl = `https://steamdatabase.s3.eu-north-1.amazonaws.com/${appId}.zip`;
            checkUrlStatus(faresUrl).then(isAvailable => {
                if (!isAvailable) {
                    button3.textContent = 'fares.top (ไม่พบ)';
                    button3.style.backgroundColor = '#555';
                    button3.style.borderColor = '#333';
                    button3.style.cursor = 'not-allowed';
                    button3.onclick = () => showMessageBox('ไม่พบไฟล์', `ไม่พบไฟล์ .zip สำหรับ App ID: ${appId} ที่ fares.top`);
                }
            });
        } else {
            button2.textContent = 'furcate.eu (ไม่มี App ID)';
            button2.style.backgroundColor = '#555';
            button2.style.borderColor = '#333';
            button2.style.cursor = 'not-allowed';
            button2.onclick = () => showMessageBox('ไม่พบ App ID', `ไม่พบ App ID สำหรับดาวน์โหลดจาก furcate.eu`);

            button3.textContent = 'fares.top (ไม่มี App ID)';
            button3.style.backgroundColor = '#555';
            button3.style.borderColor = '#333';
            button3.style.cursor = 'not-allowed';
            button3.onclick = () => showMessageBox('ไม่พบ App ID', `ไม่พบ App ID สำหรับดาวน์โหลดจาก fares.top`);
        }
    }

    // Simple VDF parser (modified slightly for robustness)
    // This function is crucial for parsing the raw data from steamui.com
    function parseVDF(text) {
        const lines = text.split('\n');
        const stack = [{}];
        let currentKey = null;

        for (let line of lines) {
            line = line.trim();
            if (line === '{') {
                const newObj = {};
                if (currentKey !== null) {
                    stack[stack.length - 1][currentKey] = newObj;
                    currentKey = null;
                }
                stack.push(newObj);
            } else if (line === '}') {
                stack.pop();
            } else if (line.length > 0) { // Ensure line is not empty
                const match = line.match(/^"([^"]+)"\s+"([^"]+)"$/); // Match "key" "value"
                if (match) {
                    const [, key, value] = match;
                    stack[stack.length - 1][key] = value;
                } else {
                    const keyMatch = line.match(/^"([^"]+)"$/); // Match "key" alone (for nested objects)
                    if (keyMatch) {
                        currentKey = keyMatch[1];
                    } else {
                        // Fallback for unquoted keys (like appid 3527290)
                        const unquotedMatch = line.match(/^([^\s]+)\s+([^\s]+)$/);
                        if (unquotedMatch) {
                            const [, key, value] = unquotedMatch;
                            stack[stack.length - 1][key] = value;
                        } else {
                             // If it's a key without a value, set it for the next block
                             currentKey = line;
                        }
                    }
                }
            }
        }
        return stack[0];
    }

    function addButtonsToPage() {
        const originalPurchaseArea = document.querySelector('div.game_area_purchase_game_wrapper > div[id^="game_area_purchase_section_add_to_cart_"]');
        const appId = window.location.pathname.split('/')[2] || '';
        const currentAppData = appData[`app:${appId}`];

        if (!originalPurchaseArea) {
            console.warn('Original purchase area not found. Cannot add custom download section.');
            return;
        }

        const customDownloadSection = document.createElement('div');
        customDownloadSection.className = 'game_area_purchase_game';
        customDownloadSection.id = 'game_area_purchase_section_download';
        customDownloadSection.setAttribute('role', 'region');
        customDownloadSection.style.marginTop = '25px';
        customDownloadSection.style.clear = 'both';
        customDownloadSection.style.marginBottom = '25px';

        const form = document.createElement('form');
        form.name = 'download_form';
        form.action = '#';
        form.method = 'POST';
        form.innerHTML = `
            <input type="hidden" name="snr" value="1_5_9__403">
            <input type="hidden" name="originating_snr" value="1_direct-navigation__">
            <input type="hidden" name="action" value="add_to_cart">
            <input type="hidden" name="sessionid" value="06f64cc5b9ac7397d92b1753">
            <input type="hidden" name="subid" value="1123983">
        `;
        customDownloadSection.appendChild(form);

        const titleElement = document.createElement('h2');
        const gameName = document.querySelector('.apphub_AppName')?.textContent || 'เกมนี้';
        titleElement.id = `${customDownloadSection.id}_title`;
        titleElement.className = 'title';
        titleElement.textContent = `ดาวน์โหลด ${gameName}`;
        customDownloadSection.setAttribute('aria-labelledby', titleElement.id);
        customDownloadSection.appendChild(titleElement);

        const gamePurchaseAction = document.createElement('div');
        gamePurchaseAction.className = 'game_purchase_action';
        customDownloadSection.appendChild(gamePurchaseAction);

        const gamePurchaseActionBg = document.createElement('div');
        gamePurchaseActionBg.className = 'game_purchase_action_bg';
        gamePurchaseAction.appendChild(gamePurchaseActionBg);

        const discountBlock = document.createElement('div');
        discountBlock.className = 'discount_block game_purchase_discount';
        discountBlock.setAttribute('data-price-final', '0');
        discountBlock.setAttribute('data-bundlediscount', '0');
        discountBlock.setAttribute('data-discount', '0');
        discountBlock.setAttribute('role', 'link');
        discountBlock.setAttribute('aria-label', `DEV/g0d`);
        discountBlock.style.backgroundColor = '#000000';

        const discountPct = document.createElement('div');
        discountPct.className = 'discount_pct';
        discountPct.style.display = 'none';
        discountBlock.appendChild(discountPct);

        const discountPrices = document.createElement('div');
        discountPrices.className = 'discount_prices';
        discountBlock.appendChild(discountPrices);

        const discountOriginalPrice = document.createElement('div');
        discountOriginalPrice.className = 'discount_original_price';
        discountOriginalPrice.style.display = 'none';
        discountPrices.appendChild(discountOriginalPrice);

        const discountFinalPrice = document.createElement('div');
        discountFinalPrice.className = 'discount_final_price';
        discountFinalPrice.style.color = '#b3b3b3';
        discountFinalPrice.textContent = 'DEV/g0d';
        discountPrices.appendChild(discountFinalPrice);

        gamePurchaseActionBg.appendChild(discountBlock);

        const hasDownloadLinks = currentAppData && (
            (currentAppData.gdownload && currentAppData.gdownload !== "") ||
            (currentAppData.fdownload && currentAppData.fdownload !== "")
        );

        if (hasDownloadLinks) {
            const downloadButtonContainer = document.createElement('div');
            downloadButtonContainer.className = 'btn_addtocart';

            const downloadButton = document.createElement('a');
            downloadButton.id = 'btn_download_dynamic';
            downloadButton.setAttribute('data-panel', '{"focusable":true,"clickOnActivate":true}');
            downloadButton.setAttribute('role', 'button');
            downloadButton.className = 'btn_green_steamui btn_medium';
            downloadButton.style.cursor = 'pointer';

            const downloadButtonSpan = document.createElement('span');
            downloadButtonSpan.textContent = 'ดาวน์โหลด';
            downloadButton.appendChild(downloadButtonSpan);

            downloadButton.addEventListener('click', createDownloadSuccessDialog);
            downloadButtonContainer.appendChild(downloadButton);
            gamePurchaseActionBg.appendChild(downloadButtonContainer);
        }

        const manifestLuaDiv = document.createElement('div');
        manifestLuaDiv.className = 'btn_addtocart btn_packageinfo';
        manifestLuaDiv.innerHTML = '<span data-panel=\'{"focusable":true,"clickOnActivate":true}\' role="button" class="btn_blue_steamui btn_medium" style="cursor: pointer;"><span>Manifest&Lua</span></span>';
        manifestLuaDiv.addEventListener('click', createAddToLibraryDialog);
        gamePurchaseActionBg.appendChild(manifestLuaDiv);


        const parentOfOriginal = originalPurchaseArea.parentNode;
        if (parentOfOriginal) {
            parentOfOriginal.insertBefore(customDownloadSection, originalPurchaseArea);
        } else {
            console.warn('Parent of original purchase area not found. Custom download section could not be inserted.');
        }
    }

    window.addEventListener('load', async () => {
        await fetchAppData();
        addButtonsToPage();
    });
})();
