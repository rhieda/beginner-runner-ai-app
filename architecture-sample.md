
MeuApp/
├── App/
│   └── MeuApp.swift              
├── Domain/                       
│   ├── Aggregates/               
│   ├── Entities/                 
│   └── Interfaces/               # Protocolos para Logger e Analytics
│       ├── LoggerProvider.swift
│       └── AnalyticsProvider.swift
├── Data/                         
│   ├── Repositories/             
│   ├── Infrastructure/           # Implementações reais de serviços externos
│   │   ├── FirebaseAnalytics.swift
│   │   ├── SentryLogger.swift
│   │   └── NetworkMonitor.swift
├── Features/                     
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardStore.swift  # O Store chama Analytics/Logger
├── Core/                         # Onde moram as classes transversais
│   ├── Observability/            
│   │   ├── AppLogger.swift       # Fachada centralizada de Logs
│   │   └── AnalyticsManager.swift # Fachada centralizada de Analytics
│   ├── Helpers/                  # Extensões e utilitários globais
│   │   ├── Date+Extensions.swift
│   │   ├── String+Validation.swift
│   │   └── View+Modifiers.swift
│   └── DesignSystem/             # Cores, fontes e componentes básicos
│       └── Components/
└── Preview Content/
