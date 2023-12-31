USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tran_master]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_master](
	[tran_id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[acc_num] [varchar](25) NULL,
	[entry_user_id] [varchar](20) NULL,
	[gl_sub_head_code] [varchar](10) NULL,
	[part_tran_srl_num] [varchar](4) NULL,
	[part_tran_type] [varchar](2) NULL,
	[ref_num] [varchar](20) NULL,
	[rpt_code] [varchar](25) NULL,
	[tran_amt] [money] NULL,
	[fl_currency] [varchar](5) NULL,
	[flc_rate] [decimal](18, 6) NULL,
	[usd_amt] [money] NULL,
	[usd_rate] [decimal](18, 6) NULL,
	[tran_date] [datetime] NULL,
	[billno] [varchar](50) NULL,
	[tran_type] [varchar](20) NULL,
	[created_date] [datetime] NULL,
	[company_id] [int] NULL,
	[CHEQUE_NO] [varchar](50) NULL,
	[RunningBalance] [money] NULL,
	[F_PRINT] [varchar](1) NULL,
	[acct_type_code] [varchar](20) NULL,
 CONSTRAINT [pk_idx_tran_master_tran_id] PRIMARY KEY CLUSTERED 
(
	[tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tran_master] ADD  CONSTRAINT [DF_tran_master_tran_amt]  DEFAULT ((0.00)) FOR [tran_amt]
GO
