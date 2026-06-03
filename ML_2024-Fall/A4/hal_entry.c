#include "hal_data.h"

FSP_CPP_HEADER
void R_BSP_WarmStart(bsp_warm_start_event_t event);
void R_IRQ_Setting();
void Initial_Setting();
void R_FND_Reset();
void R_FND_Print_Data(uint8_t *string);
void R_FND_Display_Data(uint8_t digit, uint8_t data);

FSP_CPP_FOOTER

////////////////// YOU MUST EDIT ONLY HERE ABOUT GLOBAL VARIABLE //////////////////
#define SEGMENT_INDEX         8
#define DIGIT_INDEX           4

#define PODR_INDEX_HIGH       7
#define PODR_INDEX_LOW        4
#define PODR_DIGIT_MASK       0x01E0
#define PODR_HIGH_MASK        0x7800
#define PODR_LOW_MASK         0x00F0
#define PODR_PIN_MASK         PODR_HIGH_MASK | PODR_LOW_MASK

uint8_t number[10] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xD8, 0x80, 0x90};

uint8_t print_data[4] = {0xC0, 0xC0, 0xC0, 0xC0};


////////////////// YOU MUST EDIT ONLY HERE ABOUT GLOBAL VARIABLE //////////////////


uint8_t fnd1 = 0;
uint8_t fnd2 = 0;


///////////////////////////////////////////////////////////////////////////////////

void hal_entry(void)
{
    /* TODO: add your own code here */
    R_PORT10->PCNTR1 |= (uint32_t)0x07000700; // LED1,2,3 Output Setting
    R_PORT11->PCNTR1 |= (uint32_t)0x00010001; // LED4 Output Setting
    R_IRQ_Setting();

    Initial_Setting();

    while(true)
        R_FND_Print_Data(print_data);

#if BSP_TZ_SECURE_BUILD
    /* Enter non-secure code */
    R_BSP_NonSecureEnter();
#endif
}

void R_IRQ_Setting()
{
    R_ICU_ExternalIrqOpen(&g_external_irq11_ctrl, &g_external_irq11_cfg);
    R_ICU_ExternalIrqOpen(&g_external_irq12_ctrl, &g_external_irq12_cfg);
    R_ICU_ExternalIrqOpen(&g_external_irq13_ctrl, &g_external_irq13_cfg);
    R_ICU_ExternalIrqOpen(&g_external_irq14_ctrl, &g_external_irq14_cfg);
    ///////////////////////// YOU MUST EDIT CODE HERE ///////////////////////////////////

    NVIC->ISER[0] |= (uint32_t)0x0F ; // NVIC Interrupt Set-Enable Register Setting (Using Exception Number)
    NVIC->IP[0] = (uint8_t)0x0C;
    NVIC->IP[1] = (uint8_t)0x0D;
    NVIC->IP[2] = (uint8_t)0x0E;
    NVIC->IP[3] = (uint8_t)0x0F;

    R_ICU->IRQCR_b[11].IRQMD = (uint8_t)0x00;
    R_ICU->IRQCR_b[12].IRQMD = (uint8_t)0x00;
    R_ICU->IRQCR_b[13].IRQMD = (uint8_t)0x00;
    R_ICU->IRQCR_b[14].IRQMD = (uint8_t)0x00;

    R_ICU->IELSR_b[0].IELS = (uint32_t)0x0C;
    R_ICU->IELSR_b[1].IELS = (uint32_t)0x0D;
    R_ICU->IELSR_b[2].IELS = (uint32_t)0x0E;
    R_ICU->IELSR_b[3].IELS = (uint32_t)0x0F; // ICU Event Link Select (Refer to the Table 14.4) (Port_IRQ11)


    R_PMISC->PWPR_b.B0WI = (uint8_t)0U; // PFSWE bit Write Protection Disable
    R_PMISC->PWPR_b.PFSWE = (uint8_t)1U; // PmnPFS Register Write Protection Disable

    R_PFS->PORT[0].PIN[6].PmnPFS_HA_b.ASEL = (uint16_t)0U; // Port m/n Pin Function Select: Analog Input
    R_PFS->PORT[0].PIN[6].PmnPFS_HA_b.ISEL = (uint16_t)1U; // Port m/n Pin Function Select: IRQ Input Mode
    R_PFS->PORT[0].PIN[8].PmnPFS_HA_b.ISEL = (uint16_t)1U;
    R_PFS->PORT[0].PIN[9].PmnPFS_HA_b.ISEL = (uint16_t)1U;
    R_PFS->PORT[0].PIN[10].PmnPFS_HA_b.ISEL = (uint16_t)1U;



    /////////////////////////////////////////////////////////////////////////////////////


}

void R_IRQ11_ISR(external_irq_callback_args_t *p_args)
{
    FSP_PARAMETER_NOT_USED (p_args);
    ///////////////////////// YOU MUST EDIT CODE HERE ///////////////////////////////////

    fnd1 = (uint8_t)(fnd1 + 1U) % 10U;
    print_data[0]=number[fnd1];

    /////////////////////////////////////////////////////////////////////////////////////
}

void R_IRQ12_ISR(external_irq_callback_args_t *p_args)
{
    FSP_PARAMETER_NOT_USED (p_args);
    ///////////////////////// YOU MUST EDIT CODE HERE ///////////////////////////////////

    fnd2 = (uint8_t)(fnd2 + 1U) % 10U;
    print_data[1]=number[fnd2];

    /////////////////////////////////////////////////////////////////////////////////////
}

void R_IRQ13_ISR(external_irq_callback_args_t *p_args)
{
    FSP_PARAMETER_NOT_USED (p_args);
    ///////////////////////// YOU MUST EDIT CODE HERE ///////////////////////////////////

    uint16_t result = fnd1 * fnd2;
    print_data[2] = number[result/10];
    print_data[3] = number[result%10];


    /////////////////////////////////////////////////////////////////////////////////////
}

void R_IRQ14_ISR(external_irq_callback_args_t *p_args)
{
    FSP_PARAMETER_NOT_USED (p_args);
    ///////////////////////// YOU MUST EDIT CODE HERE ///////////////////////////////////

    print_data[0]=0xC0;
    print_data[1]=0xC0;
    print_data[2]=0xC0;
    print_data[3]=0xC0;

    /////////////////////////////////////////////////////////////////////////////////////
}

void Initial_Setting()
{
    /* 7-Segment LED Pin Output Setting */
    R_PORT3->PCNTR1_b.PDR |= (uint32_t)0x01E0;
    R_PORT6->PCNTR1_b.PDR |= (uint32_t)0x78F0;

    R_FND_Reset();
}

void R_FND_Reset()
{
    /* 7-Segment LED Pin State Initialization */
    R_PORT3->PCNTR1_b.PODR &= ~PODR_DIGIT_MASK & 0xFFFF;
    R_PORT6->PCNTR1_b.PODR |= PODR_PIN_MASK;
}

void R_FND_Print_Data(uint8_t *string)
{
    uint8_t idx = 0;

    if (sizeof(string) != DIGIT_INDEX)
        return;

    for (idx = 0; idx < DIGIT_INDEX; idx++)
        R_FND_Display_Data(idx, string[idx]);
}

void R_FND_Display_Data(uint8_t digit, uint8_t data)
{

    uint16_t high_nibble = (uint16_t)((data << PODR_INDEX_HIGH) & PODR_HIGH_MASK);
    uint16_t low_nibble = (uint16_t)((data << PODR_INDEX_LOW) & PODR_LOW_MASK);

    R_BSP_SoftwareDelay(10, BSP_DELAY_UNITS_MICROSECONDS);
    R_FND_Reset();

    /* 7-Segment Digit Selection */
    R_PORT3->PCNTR1_b.PODR = (uint16_t)((0x0010 << (1 + digit)) & PODR_DIGIT_MASK);

    /* 7-Segment LED Pin State Setting */
    R_PORT6->PCNTR1_b.PODR = high_nibble | low_nibble;

}

/*******************************************************************************************************************//**
 * This function is called at various points during the startup process.  This implementation uses the event that is
 * called right before main() to set up the pins.
 *
 * @param[in]  event    Where at in the start up process the code is currently at
 **********************************************************************************************************************/
void R_BSP_WarmStart(bsp_warm_start_event_t event)
{
    if (BSP_WARM_START_RESET == event)
    {
#if BSP_FEATURE_FLASH_LP_VERSION != 0

        /* Enable reading from data flash. */
        R_FACI_LP->DFLCTL = 1U;

        /* Would normally have to wait tDSTOP(6us) for data flash recovery. Placing the enable here, before clock and
         * C runtime initialization, should negate the need for a delay since the initialization will typically take more than 6us. */
#endif
    }

    if (BSP_WARM_START_POST_C == event)
    {
        /* C runtime environment and system clocks are setup. */

        /* Configure pins. */
        R_IOPORT_Open (&g_ioport_ctrl, g_ioport.p_cfg);
    }
}

#if BSP_TZ_SECURE_BUILD

BSP_CMSE_NONSECURE_ENTRY void template_nonsecure_callable ();

/* Trustzone Secure Projects require at least one nonsecure callable function in order to build (Remove this if it is not required to build). */
BSP_CMSE_NONSECURE_ENTRY void template_nonsecure_callable ()
{

}
#endif
