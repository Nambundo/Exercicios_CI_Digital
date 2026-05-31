# Exercicios_CI_Digital

Neste repositório constam as tarefas relacionadas à semana de 25/05. Os exercícios estão organizados conforme os respetivos dias: exercício do dia 25/05 (segunda-feira), 26/05 (terça-feira) e 29/05 (sexta-feira). As pastas Doc são referentes aos relatórios dos exercícios propostos.

---

## Estrutura do Repositório

```
Exercicios_CI_Digital/
├── Ex_25_05/
│   ├── ex01/
│   │   ├── Doc/
│   │   ├── ex1_cache.v
│   │   ├── tb_ex1.v
│   │   ├── sim1
│   │   └── wave.vcd
│   └── ex02/
│       ├── Doc/
│       ├── ex2_cache.v
│       ├── tb_ex2.v
│       ├── sim2
│       └── wave_ex2.vcd
├── Ex_26_05/
│   ├── Doc/
│   │   └── Relatorio.docx
│   ├── axi4lite_regs.v
│   ├── tb_axi4lite.v
│   ├── sim_axi
│   └── wave_axi.vcd
└── Ex_29_05/
    ├── Doc/
    └── Interrupt_Controller/
        ├── src/
        │   └── intrCntrl.v
        ├── testbench/
        │   └── intrCntrl_tb.v
        └── README.md
```

---

## Exercícios

### Ex_25_05 — Cache Memory (Exercícios 01 e 02)

Implementação e simulação de módulos de memória cache em Verilog.

| Arquivo | Descrição |
|---|---|
| `ex1_cache.v` | Módulo de cache — exercício 01 |
| `tb_ex1.v` | Testbench do exercício 01 |
| `ex2_cache.v` | Módulo de cache — exercício 02 |
| `tb_ex2.v` | Testbench do exercício 02 |

**Como simular:**
```bash
# Exercício 01
iverilog -o Ex_25_05/ex01/sim1 Ex_25_05/ex01/ex1_cache.v Ex_25_05/ex01/tb_ex1.v
vvp Ex_25_05/ex01/sim1
gtkwave Ex_25_05/ex01/wave.vcd

# Exercício 02
iverilog -o Ex_25_05/ex02/sim2 Ex_25_05/ex02/ex2_cache.v Ex_25_05/ex02/tb_ex2.v
vvp Ex_25_05/ex02/sim2
gtkwave Ex_25_05/ex02/wave_ex2.vcd
```

---

### Ex_26_05 — AXI4-Lite Registers

Implementação de registradores com interface AXI4-Lite em Verilog.

| Arquivo | Descrição |
|---|---|
| `axi4lite_regs.v` | Módulo de registradores AXI4-Lite |
| `tb_axi4lite.v` | Testbench AXI4-Lite |
| `Doc/Relatorio.docx` | Relatório da atividade |

**Como simular:**
```bash
iverilog -o Ex_26_05/sim_axi Ex_26_05/axi4lite_regs.v Ex_26_05/tb_axi4lite.v
vvp Ex_26_05/sim_axi
gtkwave Ex_26_05/wave_axi.vcd
```

---

### Ex_29_05 — Interrupt Controller

Análise e simulação de um controlador de interrupções com 8 entradas, baseado no repositório público [adibis/Interrupt_Controller](https://github.com/adibis/Interrupt_Controller).

Suporta dois modos de operação:
- **Polling** — varredura sequencial das 8 fontes
- **Custom Priority** — ordem de atendimento configurável via barramento

| Arquivo | Descrição |
|---|---|
| `src/intrCntrl.v` | Módulo principal do controlador (FSM com 16 estados) |
| `testbench/intrCntrl_tb.v` | Testbench com polling (8 interrupções) e priority (10 interrupções) |

**Como simular:**
```bash
cd Ex_29_05/Interrupt_Controller
iverilog -o simulacao src/intrCntrl.v testbench/intrCntrl_tb.v
vvp simulacao
gtkwave waves.vcd
```

**Resultado esperado no terminal:**
```
======== Beginning Polling ========
...
======== Beginning Priority ========
Proper Order - 5 -> 3 -> 7 -> 0 -> 4 -> 3 -> 2 -> 5 -> 6 -> 1
...
======== All tests completed successfully ========
```

---

## Ferramentas Utilizadas

| Ferramenta | Uso |
|---|---|
| [Icarus Verilog](http://iverilog.icarus.com/) | Compilação e simulação dos módulos |
| [GTKWave](http://gtkwave.sourceforge.net/) | Visualização das formas de onda (.vcd) |
| VS Code | Edição dos arquivos Verilog |

**Instalação (Linux):**
```bash
sudo apt install iverilog gtkwave
```

**Instalação (Windows):** baixar em [bleyer.org/icarus](http://bleyer.org/icarus/) — já inclui GTKWave.

---

## Como Clonar e Submeter

```bash
git clone https://github.com/Nambundo/Exercicios_CI_Digital.git
cd Exercicios_CI_Digital

```

---

## Referências

- Repositório base Ex_29_05: https://github.com/adibis/Interrupt_Controller
- Icarus Verilog: http://iverilog.icarus.com/
- GTKWave: http://gtkwave.sourceforge.net/
