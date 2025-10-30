# 📈 MarketWatch — Desafio Técnico iOS Developer

Aplicativo desenvolvido como desafio técnico, utilizando **Swift**, **UIKit**, **RxSwift**, e integração com a **API Twelve Data** para exibição de cotações e séries temporais de ativos financeiros.

---

## 📱 Visão Geral

O **MarketWatch** é um app que permite visualizar dados de mercado em tempo real, buscar ativos e exibir gráficos de variação (time series).  
Ele foi estruturado com **arquitetura reativa (RxSwift + MVVM)**, garantindo separação de responsabilidades e testabilidade.

### Principais recursos
- 🔎 Busca de ativos e cotações via **Twelve Data API**  
- 📈 Exibição de séries temporais (gráficos)  
- ⚡ Implementação com **RxSwift e RxCocoa**  
- 🧩 Arquitetura **MVVM + Repository Pattern**  
- 🧪 Testes unitários com **Quick, Nimble e RxTest**  
- 📂 Mocks locais (`Resources/Mocks`) para fallback offline  
- 🚨 Tratamento de **rate limit e erros não bloqueantes**

---

## ⚙️ Setup do Projeto

### 1️⃣ Pré-requisitos

- Xcode 15+
- Swift 5.10+
- CocoaPods
- Conta e chave da API [Twelve Data](https://twelvedata.com/account/market-data)

### 2️⃣ Clonando o repositório

```bash
git clone https://github.com/edwylugo/MarketWatch.git
cd MarketWatch
```

### 3️⃣ Instalando dependências

```bash
pod install
```

Abra o workspace:

```bash
open MarketWatch.xcworkspace
```
---

## 🚀 Execução

Configure a API Key da Twelve Data no arquivo:

-> MarketWatch/Resources/Config.plist

---

## 🧩 Arquitetura — MVVM + Repository + RxSwift
### 🏗️ Camadas

1. Data Layer
Contém `TwelveDataService` (integração REST) e `MockTwelveDataService` (fallback offline).
O `MarketRepository` unifica o acesso aos dados e trata erros de decoding e rate limit.

2. Domain Layer
Define as entidades (`Quote`, `Asset`, `TimeSeriesPoint`) e `UseCases` (`FetchAssetsUseCase`, `SearchAssetsUseCase`).

3. Presentation Layer
Implementa os ViewModels (`AssetListViewModel`) e ViewControllers (`AssetListViewController`, `AssetDetailViewController`).
Toda a comunicação com a UI é reativa via RxSwift + RxCocoa.

---

## ⚡ Reatividade com RxSwift
### Exemplo no `AssetListViewModel`

- `flatMapLatest`: Garante que somente a última requisição ativa será considerada.
- `trackActivity`: Vincula carregamento ao estado `isLoading`.
- `catch`: Captura erros e os envia ao `errorRelay` (não bloqueante).
- `Driver` e `Signal`: Garantem thread safety e execução na main thread.

---

## 🧪 Testes Unitários

### Frameworks usados

- Quick — DSL de BDD em Swift
- Nimble — Expressões legíveis de expectativa
- RxTest / RxBlocking — Testes de streams reativos

### Estrutura dos testes

- `AssetListViewModelTests` → valida fluxo de dados, debounce de busca e estados de loading

---

## 🧰 Ferramentas e Bibliotecas

| Categoria   | Biblioteca              | Função                      |
| ----------- | ----------------------- | --------------------------- |
| Reatividade | RxSwift / RxCocoa       | Fluxos assíncronos          |
| Testes      | Quick / Nimble / RxTest | Testes unitários e reativos |
| Rede        | Alamofire               | Requests HTTP               |
| Mock        | Local JSON + Flag       | Fallback offline            |
| UI          | UIKit                   | Interface principal         |

---

## 🧠 Decisões Técnicas

- **MVVM + Repository** → separação clara entre UI, lógica e dados
- **RxSwift** → facilita reatividade e vinculação entre ViewModel e View
- **MockTwelveDataService** → garante testabilidade e offline
- **Error Handling** → não bloqueante, com `AlertBanner` e mensagens amigáveis
- **Rate Limit** → tratado via `APIError.rateLimited` com retry/backoff
- **TestScheduler** → usado nos testes para eliminar `MainScheduler` e evitar `SIGABRT`

---

## 🧾 Créditos

Desenvolvido por Edwy Lugo

📧 linkedin.com/in/edwylugo

🧰 Swift | UIKit | RxSwift | MVVM | Quick & Nimble | API Integration | Testing
