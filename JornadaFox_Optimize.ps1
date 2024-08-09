# JornadaFox_Optimize - Script para otimização completa do Firefox

# Forçar uso do TLS 1.2 e TLS 1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Tls13

# Função para instalar a fonte Merriweather
function Install-MerriweatherFont {
    $fontUrl = "https://github.com/google/fonts/raw/main/ofl/merriweather/Merriweather-Regular.ttf"
    $fontTempPath = Join-Path $env:TEMP "Merriweather-Regular.ttf"
    $fontDestPath = Join-Path $env:WINDIR "Fonts\Merriweather-Regular.ttf"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontName = "Merriweather Regular (TrueType)"
    $fontRegistryValue = "Merriweather-Regular.ttf"
    
    if (Test-Path $fontDestPath) {
        Write-Host "A fonte Merriweather já está instalada."
        return
    }

    try {
        Write-Host "Baixando e instalando a fonte Merriweather..."
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontTempPath -UseBasicParsing
        Copy-Item -Path $fontTempPath -Destination $fontDestPath -Force
        New-ItemProperty -Path $registryPath -Name $fontName -Value $fontRegistryValue -PropertyType String -Force | Out-Null
        Write-Host "Fonte Merriweather instalada com sucesso!"
    } catch {
        Write-Error "Falha ao instalar a fonte Merriweather: $($_.Exception.Message)"
    } finally {
        if (Test-Path $fontTempPath) {
            Remove-Item $fontTempPath -Force
        }
    }
}

# Função para aplicar as preferências no user.js
function Apply-FirefoxUserJs {
    param ([string]$ProfilePath)

    $userJsPath = Join-Path $ProfilePath "user.js"

    $userJsContent = @"
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
user_pref('browser.taskbar.previews.enable', false);  # Minimizar/Maximizar ao clicar no ícone
user_pref('privacy.trackingprotection.enabled', false);  # Desativar proteção aprimorada
user_pref('layout.css.prefers-color-scheme.content-override', 1);  # Forçar Aparência Clara
user_pref('browser.link.open_newwindow', 3);
user_pref('browser.cache.disk.enable', false);
user_pref('browser.chrome.site_icons', true);  # Garantir exibição de favicons
user_pref('browser.newtabpage.activity-stream.feeds.section.topstories', false);  # Desativar feeds
user_pref('dom.push.enabled', false);  # Desativar push notifications
user_pref('extensions.pocket.enabled', false);  # Desativar Pocket
user_pref('network.http.max-connections', 900);
user_pref('network.dns.disableIPv6', true);
user_pref('network.trr.mode', 3);  # Habilitar DNS over HTTPS (DoH)
user_pref('network.trr.uri', 'https://cloudflare-dns.com/dns-query');  # Usar DNS 1.1.1.1
user_pref('network.trr.bootstrapAddress', '1.1.1.1');
user_pref('network.dns.secondary', '8.8.8.8');  # DNS Secundário Google
user_pref('dom.webnotifications.enabled', false);  # Desativar notificações da web
user_pref('media.autoplay.default', 5);  # Desativar autoplay de mídia
user_pref('privacy.resistFingerprinting', true);  # Resistir ao fingerprinting
user_pref('browser.tabs.tabMinWidth', 30);  # Reduzir o tamanho mínimo das abas
user_pref('browser.tabs.tabMaxWidth', 100);  # Reduzir o tamanho máximo das abas
user_pref('browser.uidensity', 1);  # Compactar a interface para economizar espaço
user_pref('browser.tabs.closeWindowWithLastTab', false);  # Não fechar a janela com a última aba
user_pref('browser.compactmode.show', true);  # Habilitar modo compacto
user_pref('layout.css.devPixelsPerPx', '1.15');  # Ajuste da escala para melhorar a visibilidade
"@

    try {
        Set-Content -Path $userJsPath -Value $userJsContent -Encoding UTF8
        Write-Host "Arquivo user.js aplicado em: $userJsPath"
    } catch {
        Write-Error "Erro ao aplicar o user.js: $($_.Exception.Message)"
    }
}

# Função para aplicar o tema e ajustes no userChrome.css
function Apply-FirefoxUserChromeCss {
    param ([string]$ProfilePath)

    $chromeDirPath = Join-Path $ProfilePath "chrome"
    $userChromeCssPath = Join-Path $chromeDirPath "userChrome.css"

    $userChromeCssContent = @"
@namespace url('http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul');

#navigator-toolbox {
    background-color: #f9f9f9 !important;  # Cor padrão do toolbox do navegador
    border-bottom: none !important;
}

.tabbrowser-tab {
    padding: 3px 7px !important;
    border-radius: 5px !important;  # Abas arredondadas para um visual moderno
    border: none !important;
    background-color: #f9f9f9 !important;  # Cor padrão das abas
    min-width: 30px !important;  # Reduzindo ainda mais a largura das abas
    max-width: 100px !important;
    font-size: 11px !important;  # Ajuste do tamanho da fonte das abas
    text-overflow: ellipsis !important;  # Garantir que o texto não ultrapasse a aba
    transition: background-color 0.3s ease, transform 0.2s ease;  # Suavizando as transições
    margin-right: 0px !important;  # Remover espaçamento entre abas fixas
    margin-left: 0px !important;
    display: flex !important;
    align-items: center !important;  # Centralizar favicons nas abas
}

.tabbrowser-tab[selected='true'] .tab-background {
    background-color: #7AA6C7 !important;  # Tom azul mais agradável para aba selecionada
    border-radius: 5px !important;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2) !important;  # Efeito de sombra maior para aba selecionada
}

.tab-icon-image {
    margin: auto !important;  # Centralizar os favicons nas abas
    width: 18px !important;  # Ajustar tamanho do favicon para manter a harmonia
    height: 18px !important;
}

#identity-box {
    border: none !important;
    width: 28px !important;  # Ajuste do tamanho do cadeado para melhorar a estética
    height: 28px !important;
}

.titlebar-buttonbox-container {
    display: flex !important;
    justify-content: flex-end !important;
    visibility: visible !important;
}

#titlebar-buttonbox {
    -moz-appearance: none !important;
    background: none !important;
    border: none !important;
    padding: 0 !important;
    margin: 0 !important;
}

#titlebar-min, #titlebar-max, #titlebar-close {
    width: 22px !important;
    height: 22px !important;
}

#PanelUI-button {
    background: url('data:image/svg+xml;base64,...') no-repeat center center !important;
    width: 34px !important;
    height: 34px !important;
    margin: auto !important;  # Centralizar o botão
}

#appMenu-popup {
    background-color: #f9f9f9 !important;  # Cor padrão do menu do navegador
    border-radius: 8px !important;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1) !important;
    padding: 10px !important;  # Ajuste para melhorar a organização do menu
}

#appMenu-popup .panel-subview {
    background-color: #f9f9f9 !important;  # Cor padrão para submenus
    border-radius: 6px !important;
}

#appMenu-popup .panel-subview-body {
    padding: 8px !important;
}

#appMenu-popup .toolbarbutton-text {
    font-size: 13px !important;
    color: #333 !important;
}

#identity-icon-box {
    width: 72px !important;  # Ajuste de tamanho para a imagem da conta
    height: 72px !important;
    margin-right: 5px !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
}

#identity-icon {
    width: 100% !important;
    height: 100% !important;
    border-radius: 50% !important;  # Tornar a imagem circular para uma melhor estética
}

.preferences-pane {
    background-color: #f9f9f9 !important;  # Cor clara para o painel de configurações
    border-radius: 8px !important;
    padding: 15px !important;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1) !important;
}

.preferences-section {
    margin-bottom: 10px !important;
    padding: 12px !important;
    background-color: #f0f0f0 !important;  # Cor clara das seções
    border-radius: 6px !important;
}
"@

    try {
        if (-Not (Test-Path $chromeDirPath)) {
            New-Item -Path $chromeDirPath -ItemType Directory | Out-Null
            Write-Host "Diretório 'chrome' criado em: $chromeDirPath"
        }

        Set-Content -Path $userChromeCssPath -Value $userChromeCssContent -Encoding UTF8
        Write-Host "Arquivo userChrome.css aplicado em: $userChromeCssPath"
    } catch {
        Write-Error "Erro ao aplicar o userChrome.css: $($_.Exception.Message)"
    }
}

# Função para agrupar abas fixas em categorias
function GroupPinnedTabs {
    param ([string]$ProfilePath)

    $userChromeCssPath = Join-Path $ProfilePath "chrome\userChrome.css"
    
    $groupingCssContent = @"
/* Agrupamento de abas fixas */
#TabsToolbar .tabbrowser-tab[pinned][label^='Redes Sociais'] {
    background-color: #FFEEAA !important;
}
#TabsToolbar .tabbrowser-tab[pinned][label^='Email'] {
    background-color: #AAEEFF !important;
}
#TabsToolbar .tabbrowser-tab[pinned][label^='IA'] {
    background-color: #CCFFAA !important;
}
"@
    try {
        Add-Content -Path $userChromeCssPath -Value $groupingCssContent -Encoding UTF8
        Write-Host "Agrupamento de abas fixas aplicado em: $userChromeCssPath"
    } catch {
        Write-Error "Erro ao aplicar agrupamento de abas fixas: $($_.Exception.Message)"
    }
}

# Função para reiniciar o Firefox
function Restart-Firefox {
    $firefoxProcess = Get-Process -Name firefox -ErrorAction SilentlyContinue
    if ($firefoxProcess) {
        Write-Host "Reiniciando o Firefox para aplicar as mudanças..."
        Stop-Process -Name firefox -Force
        Start-Sleep -Seconds 3
        Start-Process -FilePath "C:\Program Files\Mozilla Firefox\firefox.exe"
    } else {
        Write-Host "Firefox não está em execução."
    }
}

# Função principal
function Main {
    try {
        Write-Host "Iniciando otimização do Firefox..."
        Install-MerriweatherFont

        # Aplicar ajustes a todos os perfis
        $firefoxProfilesPath = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
        if (-Not (Test-Path $firefoxProfilesPath)) {
            Write-Error "Nenhum perfil do Firefox encontrado em " + $firefoxProfilesPath
            return
        }

        $profiles = Get-ChildItem -Path $firefoxProfilesPath -Directory
        foreach ($profile in $profiles) {
            Apply-FirefoxUserJs -ProfilePath $profile.FullName
            Apply-FirefoxUserChromeCss -ProfilePath $profile.FullName
            GroupPinnedTabs -ProfilePath $profile.FullName  # Agrupamento de abas fixas
        }

        Write-Host "Otimização do Firefox concluída com sucesso!"
        Restart-Firefox
    } catch {
        Write-Error ("Erro durante a otimização: $($_.Exception.Message)")
    }
}

# Executar função principal
Main
