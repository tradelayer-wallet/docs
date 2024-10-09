

### Insurance and Liquidation

# Liquidation Price and Process

In TradeLayer, liquidation is a critical mechanism designed to protect the protocol and maintain stability in the face of adverse market conditions. The process leverages both **Liquidation Price Calculation** and an **Incremental Liquidation Mechanism** to efficiently manage under-collateralized positions.

## Liquidation Price

When a liquidation event is triggered, liquidators can specify the product and the amount they intend to liquidate. The **liquidation price** is calculated based on whether the contract is linear or inverse and whether the position is long or short. This price serves as a threshold that, if reached, initiates liquidation actions on the user's position.
### Liquidation Price

#### Linear Contracts
For **linear contracts**, the liquidation price calculation depends on whether the position is long or short:

- **Long Positions**:
  - The liquidation price \( L \) is calculated after determining the bankruptcy price \( B \), where:
	$$
	B = \left( P_{\text{avg}} - \frac{\text{Total Collateral}}{\text{Position Notional}} \right) \times 1.005
	$$
	- Here, \( P_{\text{avg}} \) is the average entry price, and the 1.005 factor applies a 0.5% buffer above the bankruptcy price.
  - The liquidation price \( L \) is then given by:
	$$
	L = B + \frac{(P_{\text{avg}} - B)}{2}
	$$

- **Short Positions**:
  - The bankruptcy price \( B \) is calculated as:
	$$
	B = \left( P_{\text{avg}} + \frac{\text{Total Collateral}}{\text{Position Notional}} \right) \times 0.995
	$$
	- This applies a 0.5% buffer below the bankruptcy price.
  - The liquidation price \( L \) is then:
	$$
	L = B - \frac{(P_{\text{avg}} + B)}{2}
	$$

#### Inverse Contracts
For **inverse contracts**, where the notional value is expressed inversely, the calculations differ slightly:

- **Long Positions**:
  - The bankruptcy price \( B \) is:
	$$
	B = \frac{\text{Position Notional} \times 1.005}{\text{Total Collateral}}
	$$
  - The liquidation price \( L \) is then determined by balancing the average price, the notional, and the bankruptcy price:
	$$
	L = P_{\text{avg}} - \frac{\left( P_{\text{avg}} \times \text{Position Notional} - 2 \times P_{\text{avg}} \times \text{Contracts} - B \times \text{Contracts} \times 1.000025 \times P_{\text{avg}} \right)}{\text{Contracts} + \text{Position Notional} - 2 \times \text{Contracts}}
	$$

- **Short Positions**:
  - For short positions, if the total collateral exceeds the notional value, there is no immediate liquidation; otherwise:
	$$
	B = \frac{\text{Position Notional} \times 0.995}{\text{Total Collateral}}
	$$
  - And the liquidation price \( L \) follows as:
	$$
	L = P_{\text{avg}} + \frac{\left( P_{\text{avg}} \times \text{Position Notional} - 2 \times P_{\text{avg}} \times \text{Contracts} - B \times \text{Contracts} \times 1.000025 \times P_{\text{avg}} \right)}{\text{Contracts} + \text{Position Notional} - 2 \times \text{Contracts}}
	$$

### Bankruptcy Price Calculation

The bankruptcy price determines the threshold at which the liquidation buffer adjusts the calculated liquidation price slightly closer to market conditions. This calculation considers total collateral relative to the position's notional value. The buffer factor (1.005 for long positions and 0.995 for short positions) provides a slight cushion, increasing the liquidation price or decreasing it respectively, which reduces volatility impact during forced liquidations.

The **bankruptcy price** is primarily calculated using:
$$
B = \left( \frac{\text{Collateral}}{\text{Position Notional}} \right) \times \text{Buffer Factor}
$$

Where:
- **Buffer Factor** is a multiplier (e.g., 1.005 for long positions) applied to set the liquidation price slightly beyond the actual bankruptcy price, mitigating risks and covering potential slippage costs during liquidation.

### Summary

By using these formulas, the system calculates liquidation prices dynamically based on the position type (long or short) and contract type (linear or inverse). Liquidators are incentivized through a buffer margin, while the insurance fund supports the system stability in cases of insolvency. This framework provides a balanced approach to ensure protocol resilience and fairness during market downturns.

In addition to the hard hand-brake liquidation price, the maintenance margin is half of the initial margin and triggers incremental liquidations of 20% of the position.

# Liquidation Process

## Step-by-Step Liquidation

1. **Trigger**: When a user’s margin falls below the required maintenance level, the system marks the position for liquidation.
2. **Selection**: Perps are presumed to be the most liquid and sold first, then futures, then short options are covered. If there are off-setting positions the net-delta of the address in that collateral and contract series will be reduced closer to 0.
3. **Execution**: Liquidation by default goes to the on-chain orderbook, which depending on AMM depth, could become know as the wood chipper by users. In the future it may be possible to flash a dutch auction starting at the maintenance price until the bankruptcy price for channel traders to single-sign a trade with the liquidation flag and front-run the AMM, which could greatly improve price execution.

## Insurance Fund Intervention

When liquidators liquidate positions, the insurance fund steps in as follows:

1. **Draws from Insurance Fund**: If an account is insolvent (i.e., liabilities exceed collateral), funds from the insurance fund are deployed to cover the deficit.
2. **Socializes Losses**: If the insurance fund is depleted, the system socializes losses across all positions based on the proportion of uPNL.

## Final Defense Mechanisms

- **Insolvent Accounts**: For accounts with insufficient USDC or collateral, the insurance fund provides additional liquidity to ensure that liquidators are compensated and the protocol remains solvent.
- **Socialization of Losses**: In extreme cases where the insurance fund is insufficient, losses are socialized across all positive balances, reducing each stakeholder’s balance proportionally to cover the deficit.

The insurance fund thus plays a crucial role in maintaining protocol stability and protecting the system from cascading failures during adverse market conditions.


_Last updated: [10*8*2024]_