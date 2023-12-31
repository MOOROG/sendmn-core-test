USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[pin_charge_history1]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pin_charge_history1](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[pin_code] [varchar](20) NULL,
	[pin_price] [money] NULL,
	[pin_new_rate] [money] NULL,
	[pinenter_date] [datetime] NULL,
	[pincharge_date] [datetime] NULL,
	[expire_date] [datetime] NULL,
	[pincharge_status] [varchar](20) NULL,
	[pincharge_by] [varchar](50) NULL,
	[verify_date] [datetime] NULL,
	[verify_by] [varchar](50) NULL,
	[agent_id] [varchar](20) NULL,
	[branch_id] [varchar](20) NULL,
	[modify_by] [varchar](20) NULL,
	[modify_date] [datetime] NULL,
	[ip] [varchar](25) NULL,
	[comp_name] [varchar](25) NULL,
	[company_name] [varchar](10) NULL,
	[pin_sn] [float] NOT NULL,
	[product] [varchar](20) NULL,
	[flag_trn] [varchar](50) NULL,
	[log_id] [varchar](20) NULL,
 CONSTRAINT [PK_pin_charge_history1] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [pin_and_product] UNIQUE NONCLUSTERED 
(
	[pin_sn] ASC,
	[product] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
